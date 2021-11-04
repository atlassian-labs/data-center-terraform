
module "vpc" {
  source = "../../modules/AWS/vpc"

  vpc_name = local.vpc_name
  vpc_tags = merge(var.resource_tags, local.required_tags)
}
