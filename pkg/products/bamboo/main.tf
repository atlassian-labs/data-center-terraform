# Create the infrastructure for Bamboo Data Center.

module "vpc" {
  source = "../../modules/AWS/vpc"

  vpc_name = var.vpc_name
  vpc_tags = merge(var.required_tags, local.required_tags)
}
