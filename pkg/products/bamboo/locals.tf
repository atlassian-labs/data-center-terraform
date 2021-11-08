locals {
  product_name = "bamboo"

  required_tags = {
    product : local.product_name
  }

  product_tags = {
    Name : local.product_name
  }

  hosted_zone_id                 = var.eks.r53_zone
  ingress_load_balancer_hostname = var.eks.ingress_load_balancer_hostname
  ingress_load_balancer_zone_id  = var.eks.ingress_load_balancer_zone_id
  product_domain_name            = "${local.product_name}.${var.ingress_dns_name}"
}