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

  region_name          = var.region
  environment_name     = var.environment_name
  resource_tags        = var.resource_tags
  vpc                  = module.base-infrastructure.vpc
  eks                  = module.base-infrastructure.eks
  efs                  = module.base-infrastructure.efs
  share_home_size      = "5Gi"
  db_allocated_storage = var.db_allocated_storage
  db_instance_class    = var.db_instance_class
  db_iops              = var.db_iops
}