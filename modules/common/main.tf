module "vpc" {
  source = "../AWS/vpc"

  vpc_name = local.vpc_name
}

module "eks" {
  source = "../AWS/eks"

  region = var.region_name

  cluster_name = local.cluster_name

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  instance_types       = var.instance_types
  instance_disk_size   = var.instance_disk_size
  max_cluster_capacity = var.max_cluster_capacity
  min_cluster_capacity = var.min_cluster_capacity
}


module "ingress" {
  source     = "../AWS/ingress"
  depends_on = [module.eks]

  # inputs
  ingress_domain           = local.ingress_domain
  enable_ssh_tcp           = var.enable_ssh_tcp
  loadBalancerSourceRanges = var.whitelist_cidr
}

resource "kubernetes_namespace" "products" {
  metadata {
    name = var.namespace
  }
}
