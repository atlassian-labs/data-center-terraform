provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "cluster" {
  name = module.base-infrastructure.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.base-infrastructure.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}


module "base-infrastructure" {
  source = "./pkg/products/common"

  region_name      = var.region
  environment_name = var.environment_name
  resource_tags    = var.resource_tags

  instance_types   = var.instance_types
  desired_capacity = var.desired_capacity
  ingress_domain   = "${var.environment_name}.${var.domain}"
}

module "bamboo" {
  source     = "./pkg/products/bamboo"
  depends_on = [module.base-infrastructure]

  region_name      = var.region
  environment_name = var.environment_name
  required_tags    = var.resource_tags
  vpc              = module.base-infrastructure.vpc
  eks              = module.base-infrastructure.eks
  efs              = module.base-infrastructure.efs
  share_home_size  = "5Gi"
}