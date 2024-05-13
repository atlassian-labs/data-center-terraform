module "base-infrastructure" {
  source = "./modules/common"

  region_name               = var.region
  environment_name          = var.environment_name
  eks_version               = var.eks_version
  tags                      = var.resource_tags
  instance_types            = var.instance_types
  instance_disk_size        = var.instance_disk_size
  max_cluster_capacity      = var.max_cluster_capacity
  min_cluster_capacity      = var.min_cluster_capacity
  cluster_downtime_start    = var.cluster_downtime_start
  cluster_downtime_stop     = var.cluster_downtime_stop
  cluster_downtime_timezone = var.cluster_downtime_timezone
  domain                    = var.domain
  namespace                 = local.namespace
  eks_additional_roles      = var.eks_additional_roles
  whitelist_cidr            = var.whitelist_cidr
  enable_https_ingress      = var.enable_https_ingress
  create_external_dns       = var.create_external_dns
  additional_namespaces     = var.additional_namespaces
  enable_ssh_tcp        = local.install_bitbucket
  osquery_secret_name   = var.osquery_fleet_enrollment_secret_name
  osquery_secret_region = var.osquery_fleet_enrollment_secret_region_aws
  osquery_env           = var.osquery_env
  osquery_version       = var.osquery_version

  kinesis_log_producers_role_arns = var.kinesis_log_producers_role_arns
  osquery_fleet_enrollment_host   = var.osquery_fleet_enrollment_host

  crowdstrike_secret_name    = var.crowdstrike_secret_name
  crowdstrike_kms_key_name   = var.crowdstrike_kms_key_name
  crowdstrike_aws_account_id = var.crowdstrike_aws_account_id
  falcon_sensor_version      = var.falcon_sensor_version

  confluence_s3_attachments_storage = var.confluence_s3_attachments_storage

  monitoring_enabled            = var.monitoring_enabled
  prometheus_pvc_disk_size      = var.prometheus_pvc_disk_size
  grafana_pvc_disk_size         = var.grafana_pvc_disk_size
  monitoring_custom_values_file = var.monitoring_custom_values_file
  monitoring_grafana_expose_lb  = var.monitoring_grafana_expose_lb

  test_deployment_cpu_request = var.test_deployment_cpu_request
  test_deployment_mem_request = var.test_deployment_mem_request
  test_deployment_cpu_limit   = var.test_deployment_cpu_limit
  test_deployment_mem_limit   = var.test_deployment_mem_limit
  test_deployment_image_repo  = var.test_deployment_image_repo
  test_deployment_image_tag   = var.test_deployment_image_tag
  start_test_deployment       = var.start_test_deployment
}

module "database" {
  source = "./modules/AWS/rds"

  count                   = length(var.products)
  vpc                     = module.base-infrastructure.vpc
  product                 = var.products[count.index]
  rds_instance_identifier = format("atlas-%s-%s-db", var.environment_name, var.products[count.index])
  allocated_storage       = local.database_settings[var.products[count.index]].db_allocated_storage
  instance_class          = local.database_settings[var.products[count.index]].db_instance_class
  iops                    = local.database_settings[var.products[count.index]].db_iops
  major_engine_version    = local.database_settings[var.products[count.index]].db_major_engine_version
  snapshot_identifier     = local.rds_snapshots[var.products[count.index]]
  db_master_username      = local.database_settings[var.products[count.index]].db_master_username
  db_master_password      = local.database_settings[var.products[count.index]].db_master_password
  db_name                 = local.database_settings[var.products[count.index]].db_name
}

module "nfs" {
  source = "./modules/AWS/nfs"

  depends_on              = [module.base-infrastructure.namespace]
  count                   = length(var.products)
  namespace               = local.namespace
  product                 = var.products[count.index]
  requests_cpu            = local.nfs_server_settings[var.products[count.index]].nfs_requests_cpu
  requests_memory         = local.nfs_server_settings[var.products[count.index]].nfs_requests_memory
  limits_cpu              = local.nfs_server_settings[var.products[count.index]].nfs_limits_cpu
  limits_memory           = local.nfs_server_settings[var.products[count.index]].nfs_limits_memory
  availability_zone       = module.base-infrastructure.eks.availability_zone
  shared_home_snapshot_id = local.nfs_server_settings[var.products[count.index]].shared_home_snapshot_id
  shared_home_size        = local.nfs_server_settings[var.products[count.index]].shared_home_size
  cluster_service_ipv4    = local.nfs_server_settings[var.products[count.index]].cluster_service_ipv4
}


module "bamboo" {
  source     = "./modules/products/bamboo"
  count      = local.install_bamboo ? 1 : 0
  depends_on = [module.nfs, module.base-infrastructure]

  environment_name = var.environment_name
  namespace        = module.base-infrastructure.namespace
  vpc              = module.base-infrastructure.vpc
  eks              = module.base-infrastructure.eks
  rds              = module.database[index(var.products, "bamboo")]
  ingress          = module.base-infrastructure.ingress

  dataset_url = var.bamboo_dataset_url

  admin_username      = var.bamboo_admin_username
  admin_password      = var.bamboo_admin_password
  admin_display_name  = var.bamboo_admin_display_name
  admin_email_address = var.bamboo_admin_email_address

  installation_timeout     = var.bamboo_installation_timeout
  termination_grace_period = var.bamboo_termination_grace_period

  bamboo_configuration = {
    helm_version       = var.bamboo_helm_chart_version
    custom_values_file = var.bamboo_custom_values_file
    cpu                = var.bamboo_cpu
    mem                = var.bamboo_mem
    min_heap           = var.bamboo_min_heap
    max_heap           = var.bamboo_max_heap
  }

  license = var.bamboo_license

  bamboo_agent_configuration = {
    helm_version = var.bamboo_agent_helm_chart_version
    cpu          = var.bamboo_agent_cpu
    mem          = var.bamboo_agent_mem
    agent_count  = var.number_of_bamboo_agents
  }

  local_home_retention_policy_when_deleted = var.bamboo_local_home_retention_policy_when_deleted
  local_home_retention_policy_when_scaled  = var.bamboo_local_home_retention_policy_when_scaled
  local_home_size                          = var.bamboo_local_home_size
  shared_home_size                         = var.bamboo_shared_home_size
  shared_home_pvc_name                     = module.nfs[index(var.products, "bamboo")].nfs_claim_name

  version_tag       = var.bamboo_version_tag
  agent_version_tag = var.bamboo_agent_version_tag

  additional_jvm_args = var.bamboo_additional_jvm_args

  # If local Helm charts path is provided, Terraform will then install using local charts and ignores remote registry
  local_bamboo_chart_path = local.local_bamboo_chart_path
  local_agent_chart_path  = local.local_agent_chart_path
}

module "jira" {
  source     = "./modules/products/jira"
  count      = local.install_jira ? 1 : 0
  depends_on = [module.nfs, module.base-infrastructure]

  environment_name = var.environment_name
  namespace        = module.base-infrastructure.namespace
  vpc              = module.base-infrastructure.vpc
  eks              = module.base-infrastructure.eks
  rds              = module.database[index(var.products, "jira")]
  ingress          = module.base-infrastructure.ingress

  db_snapshot_id = local.jira_rds_snapshot_id

  replica_count            = var.jira_replica_count
  installation_timeout     = var.jira_installation_timeout
  termination_grace_period = var.jira_termination_grace_period

  jira_configuration = {
    helm_version        = var.jira_helm_chart_version
    custom_values_file  = var.jira_custom_values_file
    cpu                 = var.jira_cpu
    mem                 = var.jira_mem
    min_heap            = var.jira_min_heap
    max_heap            = var.jira_max_heap
    reserved_code_cache = var.jira_reserved_code_cache
    license             = var.jira_license
  }
  image_repository = var.jira_image_repository
  version_tag      = var.jira_version_tag

  additional_jvm_args = var.jira_additional_jvm_args

  local_home_retention_policy_when_deleted = var.jira_local_home_retention_policy_when_deleted
  local_home_retention_policy_when_scaled  = var.jira_local_home_retention_policy_when_scaled
  local_home_size                          = var.jira_local_home_size
  shared_home_size                         = var.jira_shared_home_size
  shared_home_pvc_name                     = module.nfs[index(var.products, "jira")].nfs_claim_name

  shared_home_snapshot_id = local.jira_ebs_snapshot_id
  local_home_snapshot_id  = local.jira_local_home_snapshot_id

  # If local Helm charts path is provided, Terraform will then install using local charts and ignores remote registry
  local_jira_chart_path = local.local_jira_chart_path
}

module "confluence" {
  source     = "./modules/products/confluence"
  count      = local.install_confluence ? 1 : 0
  depends_on = [module.nfs, module.base-infrastructure]

  environment_name = var.environment_name
  namespace        = module.base-infrastructure.namespace
  region_name      = var.region
  vpc              = module.base-infrastructure.vpc
  eks              = module.base-infrastructure.eks
  rds              = module.database[index(var.products, "confluence")]
  ingress          = module.base-infrastructure.ingress

  db_snapshot_id           = local.confluence_rds_snapshot_id
  db_snapshot_build_number = local.confluence_db_snapshot_build_number

  replica_count                     = var.confluence_replica_count
  installation_timeout              = var.confluence_installation_timeout
  version_tag                       = var.confluence_version_tag
  enable_synchrony                  = var.confluence_collaborative_editing_enabled
  termination_grace_period          = var.confluence_termination_grace_period
  confluence_s3_attachments_storage = var.confluence_s3_attachments_storage

  additional_jvm_args = var.confluence_additional_jvm_args

  confluence_configuration = {
    helm_version       = var.confluence_helm_chart_version
    custom_values_file = var.confluence_custom_values_file
    cpu                = var.confluence_cpu
    mem                = var.confluence_mem
    min_heap           = var.confluence_min_heap
    max_heap           = var.confluence_max_heap
    license            = var.confluence_license
  }

  synchrony_configuration = {
    cpu        = var.synchrony_cpu
    mem        = var.synchrony_mem
    min_heap   = var.synchrony_min_heap
    max_heap   = var.synchrony_max_heap
    stack_size = var.synchrony_stack_size
  }

  local_home_retention_policy_when_deleted = var.confluence_local_home_retention_policy_when_deleted
  local_home_retention_policy_when_scaled  = var.confluence_local_home_retention_policy_when_scaled
  local_home_size                          = var.confluence_local_home_size
  shared_home_size                         = var.confluence_shared_home_size
  shared_home_pvc_name                     = module.nfs[index(var.products, "confluence")].nfs_claim_name

  shared_home_snapshot_id = local.confluence_ebs_snapshot_id
  local_home_snapshot_id  = local.confluence_local_home_snapshot_id

  # If local Helm charts path is provided, Terraform will then install using local charts and ignores remote registry
  local_confluence_chart_path = local.local_confluence_chart_path

  opensearch_enabled = var.confluence_opensearch_enabled
  opensearch_requests_cpu = var.confluence_opensearch_requests_cpu
  opensearch_requests_memory = var.confluence_opensearch_requests_memory
  opensearch_snapshot_id = var.confluence_opensearch_snapshot_id
  opensearch_persistence_size = var.confluence_opensearch_persistence_size
  opensearch_initial_admin_password = var.confluence_opensearch_initial_admin_password
}

module "bitbucket" {
  source     = "./modules/products/bitbucket"
  count      = local.install_bitbucket ? 1 : 0
  depends_on = [module.nfs, module.base-infrastructure]

  environment_name = var.environment_name
  namespace        = module.base-infrastructure.namespace
  vpc              = module.base-infrastructure.vpc
  eks              = module.base-infrastructure.eks
  rds              = module.database[index(var.products, "bitbucket")]
  ingress          = module.base-infrastructure.ingress

  db_snapshot_id = local.bitbucket_rds_snapshot_id

  replica_count            = var.bitbucket_replica_count
  installation_timeout     = var.bitbucket_installation_timeout
  termination_grace_period = var.bitbucket_termination_grace_period

  bitbucket_configuration = {
    helm_version       = var.bitbucket_helm_chart_version
    custom_values_file = var.bitbucket_custom_values_file
    cpu                = var.bitbucket_cpu
    mem                = var.bitbucket_mem
    min_heap           = var.bitbucket_min_heap
    max_heap           = var.bitbucket_max_heap
    license            = var.bitbucket_license
  }

  local_home_retention_policy_when_deleted = var.bitbucket_local_home_retention_policy_when_deleted
  local_home_retention_policy_when_scaled  = var.bitbucket_local_home_retention_policy_when_scaled
  local_home_size                          = var.bitbucket_local_home_size
  shared_home_size                         = var.bitbucket_shared_home_size
  shared_home_pvc_name                     = module.nfs[index(var.products, "bitbucket")].nfs_claim_name

  display_name = var.bitbucket_display_name

  admin_configuration = {
    admin_username      = var.bitbucket_admin_username
    admin_password      = var.bitbucket_admin_password
    admin_display_name  = var.bitbucket_admin_display_name
    admin_email_address = var.bitbucket_admin_email_address
  }
  version_tag = var.bitbucket_version_tag

  additional_jvm_args = var.bitbucket_additional_jvm_args

  opensearch_requests_cpu    = var.bitbucket_opensearch_requests_cpu
  opensearch_requests_memory = var.bitbucket_opensearch_requests_memory
  opensearch_limits_cpu      = var.bitbucket_opensearch_limits_cpu
  opensearch_limits_memory   = var.bitbucket_opensearch_limits_memory
  opensearch_storage         = var.bitbucket_opensearch_storage
  opensearch_replicas        = var.bitbucket_opensearch_replicas
  opensearch_java_opts       = var.bitbucket_opensearch_java_opts
  deploy_opensearch          = var.bitbucket_deploy_opensearch
  opensearch_secret_name     = var.bitbucket_opensearch_secret_name
  opensearch_secret_username_key = var.bitbucket_opensearch_secret_username_key
  opensearch_secret_password_key = var.bitbucket_opensearch_secret_password_key

  shared_home_snapshot_id = local.bitbucket_ebs_snapshot_id

  # If local Helm charts path is provided, Terraform will then install using local charts and ignores remote registry
  local_bitbucket_chart_path = local.local_bitbucket_chart_path
}

module "crowd" {
  source     = "./modules/products/crowd"
  count      = local.install_crowd ? 1 : 0
  depends_on = [module.nfs, module.base-infrastructure]

  environment_name = var.environment_name
  namespace        = module.base-infrastructure.namespace
  vpc              = module.base-infrastructure.vpc
  eks              = module.base-infrastructure.eks
  rds              = module.database[index(var.products, "crowd")]
  ingress          = module.base-infrastructure.ingress

  db_snapshot_id           = local.crowd_rds_snapshot_id
  db_snapshot_build_number = local.crowd_db_snapshot_build_number

  replica_count            = var.crowd_replica_count
  installation_timeout     = var.crowd_installation_timeout
  termination_grace_period = var.crowd_termination_grace_period

  crowd_configuration = {
    helm_version       = var.crowd_helm_chart_version
    custom_values_file = var.crowd_custom_values_file
    cpu                = var.crowd_cpu
    mem                = var.crowd_mem
    min_heap           = var.crowd_min_heap
    max_heap           = var.crowd_max_heap
    license            = var.crowd_license
  }
  image_repository = var.crowd_image_repository
  version_tag      = var.crowd_version_tag

  additional_jvm_args = var.crowd_additional_jvm_args

  local_home_retention_policy_when_deleted = var.crowd_local_home_retention_policy_when_deleted
  local_home_retention_policy_when_scaled  = var.crowd_local_home_retention_policy_when_scaled
  local_home_size                          = var.crowd_local_home_size
  shared_home_size                         = var.crowd_shared_home_size
  shared_home_pvc_name                     = module.nfs[index(var.products, "crowd")].nfs_claim_name
  shared_home_snapshot_id                  = local.crowd_ebs_snapshot_id

  # If local Helm charts path is provided, Terraform will then install using local charts and ignores remote registry
  local_crowd_chart_path = local.local_crowd_chart_path
}
