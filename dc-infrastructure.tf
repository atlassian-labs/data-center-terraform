module "base-infrastructure" {
  source = "./modules/common"

  region_name      = var.region
  environment_name = var.environment_name

  instance_types   = var.instance_types
  desired_capacity = var.desired_capacity
  domain           = var.domain
  namespace        = local.namespace
  share_home_size  = "5Gi"
}

module "bamboo" {
  source     = "./modules/products/bamboo"
  count      = local.install_bamboo ? 1 : 0
  depends_on = [module.base-infrastructure]

  region_name          = var.region
  environment_name     = var.environment_name
  namespace            = module.base-infrastructure.namespace
  vpc                  = module.base-infrastructure.vpc
  eks                  = module.base-infrastructure.eks
  ingress              = module.base-infrastructure.ingress
  db_allocated_storage = var.bamboo_db_allocated_storage
  db_instance_class    = var.bamboo_db_instance_class
  db_iops              = var.bamboo_db_iops

  license     = var.bamboo_license
  dataset_url = var.bamboo_dataset_url

  pvc_claim_name = module.base-infrastructure.pvc_claim_name

  admin_username      = var.bamboo_admin_username
  admin_password      = var.bamboo_admin_password
  admin_display_name  = var.bamboo_admin_display_name
  admin_email_address = var.bamboo_admin_email_address

  bamboo_configuration = {
    "helm_version" = var.bamboo_helm_chart_version
    "cpu"          = var.bamboo_cpu
    "mem"          = var.bamboo_mem
    "min_heap"     = var.bamboo_min_heap
    "max_heap"     = var.bamboo_max_heap
  }

  bamboo_agent_configuration = {
    "helm_version" = var.bamboo_agent_helm_chart_version
    "cpu"          = var.bamboo_agent_cpu
    "mem"          = var.bamboo_agent_mem
    "agent_count"  = var.number_of_bamboo_agents
  }

  # If local Helm charts path is provided, Terraform will then install using local charts and ignores remote registry
  local_bamboo_chart_path = local.local_bamboo_chart_path
  local_agent_chart_path  = local.local_agent_chart_path
}
