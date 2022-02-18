module "base-infrastructure" {
  source = "./modules/common"

  region_name      = var.region
  environment_name = var.environment_name

  instance_types   = var.instance_types
  desired_capacity = var.desired_capacity
  domain           = var.domain
  namespace        = local.namespace
  share_home_size  = "5Gi"

  create_elasticsearch         = local.create_aws_elasticsearch
  elasticsearch_instance_type  = var.bitbucket_aws_elasticsearch_instance_type
  elasticsearch_storage_size   = var.bitbucket_elasticsearch_storage
  elasticsearch_instance_count = var.bitbucket_elasticsearch_replicas

}

module "bamboo" {
  source     = "./modules/products/bamboo"
  count      = local.install_bamboo ? 1 : 0
  depends_on = [module.base-infrastructure]

  environment_name = var.environment_name
  namespace        = module.base-infrastructure.namespace
  vpc              = module.base-infrastructure.vpc
  eks              = module.base-infrastructure.eks
  ingress          = module.base-infrastructure.ingress

  dataset_url = var.bamboo_dataset_url

  pvc_claim_name = module.base-infrastructure.pvc_claim_name


  admin_username      = var.bamboo_admin_username
  admin_password      = var.bamboo_admin_password
  admin_display_name  = var.bamboo_admin_display_name
  admin_email_address = var.bamboo_admin_email_address


  db_major_engine_version = var.bamboo_db_major_engine_version
  db_configuration = {
    db_allocated_storage = var.bamboo_db_allocated_storage
    db_instance_class    = var.bamboo_db_instance_class
    db_iops              = var.bamboo_db_iops
  }

  bamboo_configuration = {
    helm_version = var.bamboo_helm_chart_version
    cpu          = var.bamboo_cpu
    mem          = var.bamboo_mem
    min_heap     = var.bamboo_min_heap
    max_heap     = var.bamboo_max_heap
    license      = var.bamboo_license
  }

  bamboo_agent_configuration = {
    helm_version = var.bamboo_agent_helm_chart_version
    cpu          = var.bamboo_agent_cpu
    mem          = var.bamboo_agent_mem
    agent_count  = var.number_of_bamboo_agents
  }

  # If local Helm charts path is provided, Terraform will then install using local charts and ignores remote registry
  local_bamboo_chart_path = local.local_bamboo_chart_path
  local_agent_chart_path  = local.local_agent_chart_path
}

module "jira" {
  source     = "./modules/products/jira"
  count      = local.install_jira ? 1 : 0
  depends_on = [module.base-infrastructure]

  environment_name        = var.environment_name
  namespace               = module.base-infrastructure.namespace
  vpc                     = module.base-infrastructure.vpc
  eks                     = module.base-infrastructure.eks
  ingress                 = module.base-infrastructure.ingress
  db_major_engine_version = var.jira_db_major_engine_version
  db_allocated_storage    = var.jira_db_allocated_storage
  db_instance_class       = var.jira_db_instance_class
  db_iops                 = var.jira_db_iops

  pvc_claim_name = module.base-infrastructure.pvc_claim_name

  jira_configuration = {
    "helm_version"        = var.jira_helm_chart_version
    "cpu"                 = var.jira_cpu
    "mem"                 = var.jira_mem
    "min_heap"            = var.jira_min_heap
    "max_heap"            = var.jira_max_heap
    "reserved_code_cache" = var.jira_reserved_code_cache
  }
}

module "confluence" {
  source     = "./modules/products/confluence"
  count      = local.install_confluence ? 1 : 0
  depends_on = [module.base-infrastructure]

  environment_name = var.environment_name
  namespace        = module.base-infrastructure.namespace
  vpc              = module.base-infrastructure.vpc
  eks              = module.base-infrastructure.eks
  ingress          = module.base-infrastructure.ingress
  pvc_claim_name   = module.base-infrastructure.pvc_claim_name

  db_major_engine_version = var.confluence_db_major_engine_version
  db_configuration = {
    db_allocated_storage = var.confluence_db_allocated_storage
    db_instance_class    = var.confluence_db_instance_class
    db_iops              = var.confluence_db_iops
  }

  confluence_configuration = {
    helm_version = var.confluence_helm_chart_version
    cpu          = var.confluence_cpu
    mem          = var.confluence_mem
    min_heap     = var.confluence_min_heap
    max_heap     = var.confluence_max_heap
    license      = var.confluence_license
  }

  enable_synchrony = var.confluence_collaborative_editing_enabled

  # If local Helm charts path is provided, Terraform will then install using local charts and ignores remote registry
  local_confluence_chart_path = local.local_confluence_chart_path
}

module "bitbucket" {
  source     = "./modules/products/bitbucket"
  count      = local.install_bitbucket ? 1 : 0
  depends_on = [module.base-infrastructure]

  environment_name        = var.environment_name
  namespace               = module.base-infrastructure.namespace
  vpc                     = module.base-infrastructure.vpc
  eks                     = module.base-infrastructure.eks
  ingress                 = module.base-infrastructure.ingress
  db_major_engine_version = var.bitbucket_db_major_engine_version
  db_allocated_storage    = var.bitbucket_db_allocated_storage
  db_instance_class       = var.bitbucket_db_instance_class
  db_iops                 = var.bitbucket_db_iops

  pvc_claim_name = module.base-infrastructure.pvc_claim_name

  bitbucket_configuration = {
    helm_version = var.bitbucket_helm_chart_version
    cpu          = var.bitbucket_cpu
    mem          = var.bitbucket_mem
    min_heap     = var.bitbucket_min_heap
    max_heap     = var.bitbucket_max_heap
    license      = var.bitbucket_license
  }

  admin_configuration = {
    admin_username      = var.bitbucket_admin_username
    admin_password      = var.bitbucket_admin_password
    admin_display_name  = var.bitbucket_admin_display_name
    admin_email_address = var.bitbucket_admin_email_address
  }

  elasticsearch_cpu      = var.bitbucket_elasticsearch_cpu
  elasticsearch_mem      = var.bitbucket_elasticsearch_mem
  elasticsearch_storage  = var.bitbucket_elasticsearch_storage
  elasticsearch_replicas = var.bitbucket_elasticsearch_replicas
  # If you want to pass an external
  elasticsearch_endpoint = var.bitbucket_external_elasticsearch_endpoint
}
