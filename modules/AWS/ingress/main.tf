# Nginx ingress using the defined DNS name. Creates AWS hosted zone and certificates automatically.
# Does NOT register a domain or create a hosted zone if the DNS name is a subdomain.

resource "aws_route53_zone" "ingress" {
  name = var.ingress_domain
}

# Create NS record for the "ingress" zone in the parent zone
# The parent zone is not managed by terraform
data "aws_route53_zone" "parent" {
  count = local.ingress_dns_is_subdomain ? 1 : 0
  name  = local.ingress_dns_domain
}

resource "aws_route53_record" "parent_ns_records" {
  # Only create parent NS records if the DNS name is a subdomain
  count = local.ingress_dns_is_subdomain ? 1 : 0

  allow_overwrite = true
  name            = var.ingress_domain
  records         = aws_route53_zone.ingress.name_servers
  ttl             = 60
  type            = "NS"
  zone_id         = data.aws_route53_zone.parent[0].zone_id
}

module "ingress_certificate" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  domain_name = "*.${var.ingress_domain}"
  zone_id     = aws_route53_zone.ingress.id

  subject_alternative_names = [
    var.ingress_domain,
  ]

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

  values = [
    yamlencode({
      controller = {
        config = {
          "use-forwarded-headers" : "true"
        }
        service = {
          ## Set external traffic policy to: "Local" to preserve source IP on providers supporting it.
          ## Ref: https://kubernetes.io/docs/tutorials/services/source-ip/#source-ip-for-services-with-typeloadbalancer
          externalTrafficPolicy = "Local"
          targetPorts = {
            # Set the HTTPS listener to accept HTTP connections only, as the AWS load balancer is terminating TLS
            https = "http" }
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-ssl-cert" : module.ingress_certificate.this_acm_certificate_arn
            "service.beta.kubernetes.io/aws-load-balancer-internal" : "false"
            "service.beta.kubernetes.io/aws-load-balancer-ip-address-type" : "dualstack"
            "service.beta.kubernetes.io/aws-load-balancer-ssl-ports" : "443"
            "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" : "http"
          }
        }
      }
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
      # reflected in the associated ELB Load Balancer. As such, the method "enable_tcp_protocol_on_lb_listener" (install.sh)
      # is executed, post deployment, to update the protocol on the load balancer from HTTP to TCP.
      #
      tcp = {
        7999: "atlassian/bitbucket:ssh"
      }
    })
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