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
          annotations = {
            # Whether the LB will be internet-facing or internal.
            # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/service/annotations/#lb-internal
            "service.beta.kubernetes.io/aws-load-balancer-internal" : "false"

            # Specifies the IP address type, in this case "dualstack" will allow clients
            # can access the load balancer using either IPv4 or IPv6.
            # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/service/annotations/#ip-address-type
            "service.beta.kubernetes.io/aws-load-balancer-ip-address-type" : "dualstack"

            # The protocol to use for backend traffic between the load balancer and the k8s pods.
            # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/service/annotations/#backend-protocol
            "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" : "http"

            # LoadBalancer is created by AWS not Terraform, so we need to add resource tags to it
            "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" : local.resource_tags
          }
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
    # Note: Although the port definition defined in step 3 is done so using the TCP protocol, this protocol is not
    # reflected in the associated ELB Load Balancer. As such, the method "enable_ssh_tcp_protocol_on_lb_listener" (install.sh)
    # is executed, post deployment, to update the protocol on the load balancer from HTTP to TCP.
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

data "aws_elb" "ingress_elb" {
  depends_on = [helm_release.ingress]
  name       = regex("(^[^-]+)", data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname)[0]
}
