# Nginx ingress using the defined DNS name. Creates AWS hosted zone and certificates automatically.
# Does NOT register a domain or create a hosted zone if the DNS name is a subdomain.

resource "aws_route53_zone" "ingress" {
  count = local.domain_supplied ? 1 : 0
  name  = var.ingress_domain
}

# Create NS record for the "ingress" zone in the parent zone
# The parent zone is not managed by terraform
data "aws_route53_zone" "parent" {
  count = local.domain_supplied ? 1 : 0
  name  = replace(var.ingress_domain, "/^[\\w-]+\\./", "")
}

resource "aws_route53_record" "parent_ns_records" {
  # Only create parent NS records if the DNS name is a subdomain
  count = local.domain_supplied ? 1 : 0

  allow_overwrite = true
  name            = var.ingress_domain
  records         = aws_route53_zone.ingress[0].name_servers
  ttl             = 60
  type            = "NS"
  zone_id         = data.aws_route53_zone.parent[0].zone_id
}

module "ingress_certificate" {
  count = local.domain_supplied ? 1 : 0

  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  domain_name = "*.${var.ingress_domain}"
  zone_id     = aws_route53_zone.ingress[0].id

  subject_alternative_names = concat([var.ingress_domain], formatlist("*.%s.${var.ingress_domain}", var.additional_namespaces))

  wait_for_validation = true
}

resource "helm_release" "ingress" {
  name       = local.ingress_name
  namespace  = local.ingress_namespace
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = local.ingress_version
  # wait for the certificate validation - https://kubernetes.github.io/ingress-nginx/deploy/#certificate-generation
  wait             = true
  create_namespace = true

  # We need to merge the list of cidrs provided in config.tfvars with the list of nat elastic IPs
  # to make sure ingresses are available when accessed from within pods and nodes of the cluster

  set {
    name  = "controller.service.loadBalancerSourceRanges"
    value = "{${join(",", concat(var.load_balancer_access_ranges, local.nat_ip_cidr))}}"
  }

  values = [
    yamlencode({
      controller = {
        config = {
          # If true, NGINX passes the incoming "X-Forwarded-*" headers to upstreams.
          # https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#use-forwarded-headers
          # https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/x-forwarded-headers.html
          "use-forwarded-headers" : "true"
        }
        service = {
          # The value "Local" preserves the client source IP.
          # https://kubernetes.io/docs/tutorials/services/source-ip/#source-ip-for-services-with-typeloadbalancer
          externalTrafficPolicy = "Local"

          enableHttps = local.enable_https_ingress

          targetPorts = {
            # Set the HTTPS listener to accept HTTP connections only, as the AWS load
            # balancer is terminating TLS.
            https = "http"
          }
          annotations = local.load_balancer_annotations
        }
      }
    }),

    # Ingress resources do not support TCP or UDP services. Support is therefore supplied by the Ingress NGINX
    # controller through the --tcp-services-configmap and --udp-services-configmap flags. These flags point to
    # an existing config map where; the key is the external port to use, and the value indicates the service to
    # expose. For more detail see, exposing TCP and UDP services:
    # https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/exposing-tcp-udp-services.md
    #
    # The inclusion of the tcp stanza below will result in the following when the ingress-nginx helm chart is deployed:
    # 1. Creation of a config map, as described above, defining how inbound TCP traffic, on port 7999, should be routed,
    #    and to which backend service
    # 2. Update the controllers deployment, to include the "--tcp-services-configmap" flag pointing to this config map
    # 3. Addition of a port definition for 7999 on the controllers service
    #
    # These 3 steps are effectively what is documented here:
    # https://atlassian.github.io/data-center-helm-charts/examples/bitbucket/BITBUCKET_SSH/#nginx-ingress-controller-config-for-ssh-connections
    #
    # Note: When enable_ssh_tcp is true, this deployment uses NLB (Network Load Balancer) instead of Classic ELB.
    # NLB natively supports TCP protocol for all ports, eliminating the need for post-deployment listener fixes.
    # For Classic ELB (when enable_ssh_tcp is false), only HTTP/HTTPS protocols are used.
    #
    local.aws_load_balancer_ssl_cert,
    local.aws_load_balancer_ssl_ports,
    local.ssh_tcp_setting,
  ]
}

# To create product specific r53 records we need to expose ingress controller information
data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = helm_release.ingress.metadata[0].namespace
  }
}

data "aws_lb" "ingress_lb" {
  depends_on = [helm_release.ingress]
  name       = regex("(^[^-]+)", data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname)[0]
}

data "aws_region" "current" {}
