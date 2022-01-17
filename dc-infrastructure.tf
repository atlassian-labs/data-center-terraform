module "base-infrastructure" {
  source = "./modules/common"

  region_name      = var.region
  environment_name = var.environment_name

  instance_types   = var.instance_types
  desired_capacity = var.desired_capacity
  domain           = var.domain
}

module "bamboo" {
  source = "./modules/products/bamboo"

  region_name          = var.region
  environment_name     = var.environment_name
  vpc                  = module.base-infrastructure.vpc
  eks                  = module.base-infrastructure.eks
  efs                  = module.base-infrastructure.efs
  ingress              = module.base-infrastructure.ingress
  share_home_size      = "5Gi"
  db_allocated_storage = var.db_allocated_storage
  db_instance_class    = var.db_instance_class
  db_iops              = var.db_iops

  license     = var.bamboo_license
  dataset_url = var.dataset_url

  admin_username      = var.bamboo_admin_username
  admin_password      = var.bamboo_admin_password
  admin_display_name  = var.bamboo_admin_display_name
  admin_email_address = var.bamboo_admin_email_address

  number_of_agents = var.number_of_bamboo_agents
}