provider "aws" {
  region = var.region
}

module "bamboo" {
  source = "./pkg/products/bamboo"

  region_name      = var.region
  environment_name = var.environment_name
  required_tags    = var.resource_tags
}