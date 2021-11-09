locals {
  product_name = "bamboo"

  required_tags = {
    product : local.product_name
  }

  product_tags = {
    Name : local.product_name
  }

  hosted_zone_id                 = var.eks.ingress.r53_zone
  ingress_load_balancer_hostname = var.eks.ingress.lb_hostname
  ingress_load_balancer_zone_id  = var.eks.ingress.lb_zone_id
  product_domain_name            = "${local.product_name}.${var.eks.ingress.domain}"
}