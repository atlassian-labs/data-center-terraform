module "vpc" {
  source = "../AWS/vpc"

  vpc_name = local.vpc_name
}

module "eks" {
  source = "../AWS/eks"

  region                          = var.region_name
  cluster_name                    = local.cluster_name
  tags                            = var.tags
  vpc_id                          = module.vpc.vpc_id
  subnets                         = module.vpc.private_subnets
  instance_types                  = var.instance_types
  instance_disk_size              = var.instance_disk_size
  max_cluster_capacity            = var.max_cluster_capacity
  min_cluster_capacity            = var.min_cluster_capacity
  additional_roles                = var.eks_additional_roles
  osquery_secret_name             = var.osquery_secret_name
  osquery_secret_region           = var.osquery_secret_region
  osquery_env                     = var.osquery_env
  osquery_version                 = var.osquery_version
  kinesis_log_producers_role_arns = var.kinesis_log_producers_role_arns
}


module "ingress" {
  source     = "../AWS/ingress"
  depends_on = [module.eks]

  # inputs
  ingress_domain              = local.ingress_domain
  enable_ssh_tcp              = var.enable_ssh_tcp
  load_balancer_access_ranges = var.whitelist_cidr
  enable_https_ingress        = var.enable_https_ingress
}

resource "kubernetes_namespace" "products" {
  metadata {
    name = var.namespace
  }
}
