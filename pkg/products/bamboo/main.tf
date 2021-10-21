# Create the infrastructure for Bamboo Data Center.

module "vpc" {
  source = "../../modules/AWS/vpc"

  product_name  = "bamboo"
  vpc_name      = var.vpc_name
  cluster_name  = var.cluster_name
  required_tags = merge(var.required_tags, local.required_tags)
  vpc_cidr      = var.vpc_cidr
}
