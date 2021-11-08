provider "aws" {
  region = var.region
}

module "base-infrastructure" {
  source = "./pkg/products/common"

  region_name      = var.region
  environment_name = var.environment_name
  resource_tags    = var.resource_tags

  instance_types   = var.instance_types
  desired_capacity = var.desired_capacity
  ingress_dns_name = "${var.environment_name}.${var.ingress_dns_name}"
}

module "bamboo" {
  source     = "./pkg/products/bamboo"
  depends_on = [module.base-infrastructure]

  region_name      = var.region
  environment_name = var.environment_name
  required_tags    = var.resource_tags
  vpc              = module.base-infrastructure.vpc
  eks              = module.base-infrastructure.eks

  ingress_dns_name = "${var.environment_name}.${var.ingress_dns_name}"
}