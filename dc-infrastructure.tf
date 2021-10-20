provider "aws" {
  region = local.region
}

module "bamboo" {
  source = "./src/products/bamboo"

  region_name   = local.region
  cluster_name  = local.cluster_name
  vpc_name      = local.vpc_name
  vpc_cidr      = local.vpc_cidr
  required_tags = local.required_tags
}