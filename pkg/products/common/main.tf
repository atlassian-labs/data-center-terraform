module "vpc" {
  source = "../../modules/AWS/vpc"

  vpc_name = local.vpc_name
  vpc_tags = merge(var.resource_tags, local.required_tags)
}

module "eks" {
  source = "../../modules/AWS/eks"

  cluster_name = local.cluster_name

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  instance_types   = var.instance_types
  desired_capacity = var.desired_capacity

  eks_tags = merge(var.resource_tags, local.required_tags)

  ingress_domain = var.ingress_domain
}

module "efs" {
  source = "../../modules/AWS/efs"

  region_name                  = var.region_name
  vpc                          = module.vpc
  eks                          = module.eks
  csi_controller_replica_count = var.desired_capacity
  efs_tags                     = merge(var.resource_tags, local.required_tags)
}