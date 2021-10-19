# Create the infrastructure for Bamboo Data Center.

module "vpc" {
  source = "../../modules/AWS/vpc"

  vpc_name           = var.cluster_name
  required_tags      = merge(var.required_tags, local.required_tags)
  vpc_cidr           = local.vpc_cidr
}
