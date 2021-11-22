locals {
  product_name = "bamboo"

  product_domain_name = "${local.product_name}.${var.eks.ingress.domain}"

  rds_instance_name = format("atlassian-dc-%s-%s-db", var.environment_name, local.product_name)
}