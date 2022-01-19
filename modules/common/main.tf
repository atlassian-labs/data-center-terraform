module "vpc" {
  source = "../AWS/vpc"

  vpc_name = local.vpc_name
}

module "eks" {
  source = "../AWS/eks"

  cluster_name = local.cluster_name
  region_name  = var.region_name

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  instance_types   = var.instance_types
  desired_capacity = var.desired_capacity
}

module "efs" {
  source = "../AWS/efs"

  efs_name                     = local.efs_name
  region_name                  = var.region_name
  vpc                          = module.vpc
  eks                          = module.eks
  csi_controller_replica_count = var.desired_capacity
}

module "ingress" {
  count = local.ingress_domain != null ? 1 : 0

  source     = "../AWS/ingress"
  depends_on = [module.eks]

  # inputs
  ingress_domain = local.ingress_domain
}
