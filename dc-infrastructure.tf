module "base-infrastructure" {
  source = "./modules/common"

  region_name      = var.region
  environment_name = var.environment_name

  instance_types   = var.instance_types
  desired_capacity = var.desired_capacity
  domain           = var.domain
}

module "monitoring" {
  source = "./modules/monitoring"

  eks_cluster_ca_certificate = module.base-infrastructure.eks.kubernetes_provider_config.cluster_ca_certificate
  eks_cluster_name           = module.base-infrastructure.eks.cluster_name
  eks_host                   = module.base-infrastructure.eks.kubernetes_provider_config.host
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
}

module "jira" {
  source = "./modules/products/jira"

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

  license = var.jira_license

  jira_configuration = {
    "helm_version" = var.jira_helm_chart_version
    "cpu"          = var.jira_cpu
    "mem"          = var.jira_mem
    "min_heap"     = var.jira_min_heap
    "max_heap"     = var.jira_max_heap
  }
}

module "confluence" {
  source = "./modules/products/confluence"

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

  license = var.confluence_license

  confluence_configuration = {
    "helm_version" = var.confluence_helm_chart_version
    "cpu"          = var.confluence_cpu
    "mem"          = var.confluence_mem
    "min_heap"     = var.confluence_min_heap
    "max_heap"     = var.confluence_max_heap
  }
}

module "bitbucket" {
  source = "./modules/products/bitbucket"

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

  license = var.bitbucket_license

  admin_username      = var.bitbucket_admin_username
  admin_password      = var.bitbucket_admin_password
  admin_display_name  = var.bitbucket_admin_display_name
  admin_email_address = var.bitbucket_admin_email_address

  bitbucket_configuration = {
    "helm_version" = var.bitbucket_helm_chart_version
    "cpu"          = var.bitbucket_cpu
    "mem"          = var.bitbucket_mem
    "min_heap"     = var.bitbucket_min_heap
    "max_heap"     = var.bitbucket_max_heap
  }
}