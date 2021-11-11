locals {
  product_name = "bamboo"

  required_tags = {
    product : local.product_name
  }

  product_tags = {
    Name : local.product_name
  }

  kubernetes_namespace = "bamboo"

  product_domain_name = "${local.product_name}.${var.eks.ingress.domain}"
}