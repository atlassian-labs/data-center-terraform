# Nginx ingress using the defined DNS name. Creates AWS hosted zone and certificates automatically.
# Does NOT register a domain or create a hosted zone if the DNS name is a subdomain.

resource "kubernetes_namespace" "ingress" {
  depends_on = [module.eks]

  metadata {
    name = local.ingress_namespace
  }
}

resource "aws_route53_zone" "ingress" {
  name = var.ingress_domain

  tags = var.eks_tags
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

resource "helm_release" "ingress" {
  depends_on = [module.eks]

  name       = local.ingress_name
  namespace  = kubernetes_namespace.ingress.metadata[0].name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = local.ingress_version

  values = [
    yamlencode({
      controller = {
        config = {
          "use-forwarded-headers" : "true"
        }
        service = {
          targetPorts = {
            # Set the HTTPS listener to accept HTTP connections only, as the AWS loadbalancer is terminating TLS
            https = "http"
          }
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-internal" : "false"
            "service.beta.kubernetes.io/aws-load-balancer-ip-address-type" : "dualstack"
            "service.beta.kubernetes.io/aws-load-balancer-ssl-ports" : "443"
            "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" : "http"
            "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" : join(",", [for k, v in var.eks_tags : "${k}=${v}"])
          }
        }
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
  name = regex("(^[^-]+)", data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname)[0]
}