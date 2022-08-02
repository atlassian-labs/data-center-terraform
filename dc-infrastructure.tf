module "base-infrastructure" {
  source = "./modules/common"

  region_name      = var.region
  environment_name = var.environment_name

  instance_types       = var.instance_types
  instance_disk_size   = var.instance_disk_size
  max_cluster_capacity = var.max_cluster_capacity
  min_cluster_capacity = var.min_cluster_capacity
  domain               = var.domain
  namespace            = local.namespace
  whitelist_cidr       = var.whitelist_cidr

  enable_ssh_tcp = local.install_bitbucket
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

  admin_username      = var.bamboo_admin_username
  admin_password      = var.bamboo_admin_password
  admin_display_name  = var.bamboo_admin_display_name
  admin_email_address = var.bamboo_admin_email_address

  db_major_engine_version = var.bamboo_db_major_engine_version
  db_configuration = {
    db_allocated_storage = var.bamboo_db_allocated_storage
    db_instance_class    = var.bamboo_db_instance_class
    db_iops              = var.bamboo_db_iops
    db_name              = var.bamboo_db_name
  }

  installation_timeout = var.bamboo_installation_timeout

  bamboo_configuration = {
    helm_version = var.bamboo_helm_chart_version
    cpu          = var.bamboo_cpu
    mem          = var.bamboo_mem
    min_heap     = var.bamboo_min_heap
    max_heap     = var.bamboo_max_heap
  }

  license = var.bamboo_license

  bamboo_agent_configuration = {
    helm_version = var.bamboo_agent_helm_chart_version
    cpu          = var.bamboo_agent_cpu
    mem          = var.bamboo_agent_mem
    agent_count  = var.number_of_bamboo_agents
  }

  local_home_size  = var.bamboo_local_home_size
  shared_home_size = var.bamboo_shared_home_size

  nfs_requests_cpu    = var.bamboo_nfs_requests_cpu
  nfs_requests_memory = var.bamboo_nfs_requests_memory
  nfs_limits_cpu      = var.bamboo_nfs_limits_cpu
  nfs_limits_memory   = var.bamboo_nfs_limits_memory

  version_tag       = var.bamboo_version_tag
  agent_version_tag = var.bamboo_agent_version_tag

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
  db_name                 = var.jira_db_name
  db_snapshot_id          = var.jira_db_snapshot_id
  db_master_username      = var.jira_db_master_username
  db_master_password      = var.jira_db_master_password

  replica_count        = var.jira_replica_count
  installation_timeout = var.jira_installation_timeout

  jira_configuration = {
    helm_version        = var.jira_helm_chart_version
    cpu                 = var.jira_cpu
    mem                 = var.jira_mem
    min_heap            = var.jira_min_heap
    max_heap            = var.jira_max_heap
    reserved_code_cache = var.jira_reserved_code_cache
    license             = var.jira_license
  }
  image_repository = var.jira_image_repository
  version_tag      = var.jira_version_tag

  local_home_size  = var.jira_local_home_size
  shared_home_size = var.jira_shared_home_size

  nfs_requests_cpu    = var.jira_nfs_requests_cpu
  nfs_requests_memory = var.jira_nfs_requests_memory
  nfs_limits_cpu      = var.jira_nfs_limits_cpu
  nfs_limits_memory   = var.jira_nfs_limits_memory

  shared_home_snapshot_id = var.jira_shared_home_snapshot_id
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

  db_major_engine_version = var.confluence_db_major_engine_version
  db_configuration = {
    db_allocated_storage = var.confluence_db_allocated_storage
    db_instance_class    = var.confluence_db_instance_class
    db_iops              = var.confluence_db_iops
    db_name              = var.confluence_db_name
  }

  db_snapshot_id           = var.confluence_db_snapshot_id
  db_snapshot_build_number = var.confluence_db_snapshot_build_number
  db_master_username       = var.confluence_db_master_username
  db_master_password       = var.confluence_db_master_password

  replica_count        = var.confluence_replica_count
  installation_timeout = var.confluence_installation_timeout
  version_tag          = var.confluence_version_tag
  enable_synchrony     = var.confluence_collaborative_editing_enabled

  confluence_configuration = {
    helm_version = var.confluence_helm_chart_version
    cpu          = var.confluence_cpu
    mem          = var.confluence_mem
    min_heap     = var.confluence_min_heap
    max_heap     = var.confluence_max_heap
    license      = var.confluence_license
  }

  local_home_size  = var.confluence_local_home_size
  shared_home_size = var.confluence_shared_home_size

  nfs_requests_cpu    = var.confluence_nfs_requests_cpu
  nfs_requests_memory = var.confluence_nfs_requests_memory
  nfs_limits_cpu      = var.confluence_nfs_limits_cpu
  nfs_limits_memory   = var.confluence_nfs_limits_memory

  shared_home_snapshot_id = var.confluence_shared_home_snapshot_id

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
  db_name                 = var.bitbucket_db_name
  db_snapshot_id          = var.bitbucket_db_snapshot_id
  db_master_username      = var.bitbucket_db_master_username
  db_master_password      = var.bitbucket_db_master_password

  replica_count        = var.bitbucket_replica_count
  installation_timeout = var.bitbucket_installation_timeout

  bitbucket_configuration = {
    helm_version = var.bitbucket_helm_chart_version
    cpu          = var.bitbucket_cpu
    mem          = var.bitbucket_mem
    min_heap     = var.bitbucket_min_heap
    max_heap     = var.bitbucket_max_heap
    license      = var.bitbucket_license
  }

  local_home_size  = var.bitbucket_local_home_size
  shared_home_size = var.bitbucket_shared_home_size

  display_name = var.bitbucket_display_name

  admin_configuration = {
    admin_username      = var.bitbucket_admin_username
    admin_password      = var.bitbucket_admin_password
    admin_display_name  = var.bitbucket_admin_display_name
    admin_email_address = var.bitbucket_admin_email_address
  }
  version_tag = var.bitbucket_version_tag

  nfs_requests_cpu    = var.bitbucket_nfs_requests_cpu
  nfs_requests_memory = var.bitbucket_nfs_requests_memory
  nfs_limits_cpu      = var.bitbucket_nfs_limits_cpu
  nfs_limits_memory   = var.bitbucket_nfs_limits_memory

  elasticsearch_requests_cpu    = var.bitbucket_elasticsearch_requests_cpu
  elasticsearch_requests_memory = var.bitbucket_elasticsearch_requests_memory
  elasticsearch_limits_cpu      = var.bitbucket_elasticsearch_limits_cpu
  elasticsearch_limits_memory   = var.bitbucket_elasticsearch_limits_memory
  elasticsearch_storage         = var.bitbucket_elasticsearch_storage
  elasticsearch_replicas        = var.bitbucket_elasticsearch_replicas

  shared_home_snapshot_id = var.bitbucket_shared_home_snapshot_id
}
