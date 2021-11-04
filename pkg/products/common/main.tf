
module "vpc" {
  source = "../../modules/AWS/vpc"

  vpc_name = local.vpc_name
  vpc_tags = var.resource_tags
}
