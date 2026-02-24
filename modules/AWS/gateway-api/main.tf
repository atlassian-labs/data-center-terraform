################################################################################
# Route53 zone and ACM certificate
################################################################################

resource "aws_route53_zone" "gateway" {
  count = local.domain_supplied ? 1 : 0
  name  = var.ingress_domain
}

data "aws_route53_zone" "parent" {
  count = local.domain_supplied ? 1 : 0
  name  = replace(var.ingress_domain, "/^[\\w-]+\\./", "")
}

resource "aws_route53_record" "parent_ns_records" {
  count = local.domain_supplied ? 1 : 0

  allow_overwrite = true
  name            = var.ingress_domain
  records         = aws_route53_zone.gateway[0].name_servers
  ttl             = 60
  type            = "NS"
  zone_id         = data.aws_route53_zone.parent[0].zone_id
}

module "gateway_certificate" {
  count = local.domain_supplied ? 1 : 0

  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  domain_name = "*.${var.ingress_domain}"
  zone_id     = aws_route53_zone.gateway[0].id

  subject_alternative_names = concat([var.ingress_domain], formatlist("*.%s.${var.ingress_domain}", var.additional_namespaces))

  wait_for_validation = true
}

################################################################################
# Gateway API CRDs (standard channel)
################################################################################

resource "null_resource" "gateway_api_crds" {
  triggers = {
    crd_url      = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v${local.gateway_api_version}/experimental-install.yaml"
    cluster_name = var.cluster_name
    region       = var.region
  }

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${self.triggers.cluster_name} --region ${self.triggers.region} && kubectl apply -f ${self.triggers.crd_url}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "aws eks update-kubeconfig --name ${self.triggers.cluster_name} --region ${self.triggers.region} 2>/dev/null; kubectl delete -f ${self.triggers.crd_url} --ignore-not-found || echo 'WARNING: CRD cleanup failed — CRDs will be removed when the EKS cluster is destroyed'"
  }
}

################################################################################
# Envoy Gateway controller
################################################################################

resource "helm_release" "envoy_gateway" {
  depends_on = [null_resource.gateway_api_crds]

  name             = "eg"
  namespace        = "envoy-gateway-system"
  create_namespace = true
  repository       = "oci://docker.io/envoyproxy"
  chart            = "gateway-helm"
  version          = local.envoy_gateway_version
  wait             = true
  timeout          = 600
}

################################################################################
# EnvoyProxy: NLB annotations and TLS termination at the LB layer
################################################################################

resource "kubectl_manifest" "envoy_proxy_config" {
  depends_on = [helm_release.envoy_gateway]

  yaml_body = <<-YAML
    apiVersion: gateway.envoyproxy.io/v1alpha1
    kind: EnvoyProxy
    metadata:
      name: atlassian-proxy-config
      namespace: envoy-gateway-system
    spec:
      provider:
        type: Kubernetes
        kubernetes:
          envoyService:
            type: LoadBalancer
            annotations:
              service.beta.kubernetes.io/aws-load-balancer-type: nlb
              service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
              service.beta.kubernetes.io/aws-load-balancer-ip-address-type: dualstack
              service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
              service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags: '${local.resource_tags}'
%{if local.domain_supplied}
              service.beta.kubernetes.io/aws-load-balancer-ssl-cert: '${module.gateway_certificate[0].this_acm_certificate_arn}'
              service.beta.kubernetes.io/aws-load-balancer-ssl-ports: '443'
              service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy: 'ELBSecurityPolicy-TLS-1-2-2017-01'
%{endif}
  YAML
}

################################################################################
# GatewayClass → EnvoyProxy config
################################################################################

resource "kubectl_manifest" "gateway_class" {
  depends_on = [kubectl_manifest.envoy_proxy_config]

  yaml_body = <<-YAML
    apiVersion: gateway.networking.k8s.io/v1
    kind: GatewayClass
    metadata:
      name: eg
    spec:
      controllerName: gateway.envoyproxy.io/gatewayclass-controller
      parametersRef:
        group: gateway.envoyproxy.io
        kind: EnvoyProxy
        name: atlassian-proxy-config
        namespace: envoy-gateway-system
  YAML
}

################################################################################
# Gateway
################################################################################

resource "kubectl_manifest" "gateway" {
  depends_on = [kubectl_manifest.gateway_class]

  yaml_body = <<-YAML
    apiVersion: gateway.networking.k8s.io/v1
    kind: Gateway
    metadata:
      name: ${local.gateway_name}
      namespace: ${var.namespace}
    spec:
      gatewayClassName: eg
      listeners:
      - name: http
        protocol: HTTP
        port: 80
        allowedRoutes:
          namespaces:
            from: Same
      - name: https
        protocol: HTTP
        port: 443
        allowedRoutes:
          namespaces:
            from: Same
      - name: ssh
        protocol: TCP
        port: 7999
        allowedRoutes:
          namespaces:
            from: Same
  YAML
}

################################################################################
# Bitbucket SSH: TCPRoute for port 7999
################################################################################

resource "kubectl_manifest" "bitbucket_ssh_tcproute" {
  depends_on = [kubectl_manifest.gateway]

  yaml_body = <<-YAML
    apiVersion: gateway.networking.k8s.io/v1alpha2
    kind: TCPRoute
    metadata:
      name: bitbucket-ssh
      namespace: ${var.namespace}
    spec:
      parentRefs:
      - name: ${local.gateway_name}
      rules:
      - backendRefs:
        - name: bitbucket
          port: 7999
  YAML
}

################################################################################
# Wait for Gateway to be Programmed, then read hostname from its status.
################################################################################

resource "time_sleep" "nlb_cleanup" {
  depends_on       = [kubectl_manifest.gateway]
  destroy_duration = "120s"
}

resource "null_resource" "wait_for_lb" {
  depends_on = [time_sleep.nlb_cleanup]

  triggers = {
    gateway_id   = kubectl_manifest.gateway.uid
    cluster_name = var.cluster_name
    region       = var.region
    namespace    = var.namespace
    gateway_name = local.gateway_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig --name ${self.triggers.cluster_name} --region ${self.triggers.region} && \
      kubectl wait --for=condition=Programmed \
        gateway/${self.triggers.gateway_name} -n ${self.triggers.namespace} --timeout=600s
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      aws eks update-kubeconfig --name ${self.triggers.cluster_name} --region ${self.triggers.region} 2>/dev/null; \
      kubectl delete svc -n envoy-gateway-system \
        -l gateway.envoyproxy.io/owning-gateway-namespace=${self.triggers.namespace},gateway.envoyproxy.io/owning-gateway-name=${self.triggers.gateway_name} \
        --ignore-not-found --wait --timeout=180s || \
      echo 'WARNING: Service cleanup failed'
    EOT
  }
}

data "external" "gateway_address" {
  depends_on = [null_resource.wait_for_lb]

  program = ["bash", "-c",
    "printf '{\"hostname\":\"%s\"}' $(kubectl get gateway ${local.gateway_name} -n ${var.namespace} -o jsonpath='{.status.addresses[0].value}')"
  ]
}

data "aws_lb" "gateway_nlb" {
  name = regex("^(.+)-[^-]+\\.elb\\.", data.external.gateway_address.result.hostname)[0]
}
