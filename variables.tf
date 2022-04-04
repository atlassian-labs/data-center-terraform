# To customise the infrastructure you must provide the value for each of these parameters in config.tfvar

################################################################################
# Common Variables
################################################################################

variable "region" {
  description = "Name of the AWS region."
  type        = string
  validation {
    condition     = can(regex("(us(-gov)?|ap|ca|cn|eu|sa)-(central|(north|south)?(east|west)?)-[1-9]", var.region))
    error_message = "Invalid region name. Must be a valid AWS region."
  }
}

variable "environment_name" {
  description = "Name for this environment that is going to be deployed. The value will be used to form the name of some resources."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9\\-]{1,24}$", var.environment_name))
    error_message = "Invalid environment name. Valid name is up to 24 characters starting with lower case alphabet and followed by alphanumerics. '-' is allowed as well."
  }
}

variable "products" {
  description = "List of the products to be installed."
  type        = list(string)
  validation {
    condition     = alltrue([for o in var.products : contains(["jira", "bitbucket", "confluence", "bamboo"], lower(o))])
    error_message = "Non-supported product is provided. Only 'jira', 'bitbucket', 'confluence',  and 'bamboo' are supported."
  }
}

variable "resource_tags" {
  description = "Additional tags for all resources to be created."
  default = {
    Terraform = "true"
  }
  type = map(string)
}

variable "instance_types" {
  description = "Instance types that is preferred for node group."
  default     = ["m5.xlarge"]
  type        = list(string)
}

variable "instance_disk_size" {
  description = "Size of the disk attached to the cluster instance."
  default     = 50
  type        = number
}

variable "min_cluster_capacity" {
  description = "Minimum number of EC2 nodes for the EKS cluster"
  default     = 1
  type        = number
  validation {
    condition     = var.min_cluster_capacity > 0 && var.min_cluster_capacity <= 20
    error_message = "Minimum cluster capacity must be between 1 and 20 (included)."
  }
}

variable "max_cluster_capacity" {
  description = "Maximum number of EC2 nodes that cluster can scale up to."
  default     = 5
  type        = number
  validation {
    condition     = var.max_cluster_capacity > 0 && var.max_cluster_capacity <= 20
    error_message = "Maximum cluster capacity must be between 1 and 20 (included)."
  }
}

variable "domain" {
  description = "Domain name base for the ingress controller. The final domain is subdomain within this domain. (eg.: environment.domain.com)"
  default     = null
  type        = string
  validation {
    condition     = can(regex("^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", var.domain)) || var.domain == null
    error_message = "Invalid domain name. Valid name is up to 63 characters starting with alphabet and followed by alphanumerics. '-' is allowed as well."
  }
}

variable "local_helm_charts_path" {
  description = "Path to a local directory with Helm charts to install"
  default     = ""
  type        = string
  validation {
    condition     = can(regex("^[.?\\/?[a-zA-Z0-9|\\-|_]*]*$", var.local_helm_charts_path))
    error_message = "Invalid local Helm chart path."
  }
}

################################################################################
# Jira Settings
################################################################################

variable "jira_helm_chart_version" {
  description = "Version of Jira Helm chart"
  type        = string
  default     = "1.2.0"
}

variable "jira_version_tag" {
  description = "Version of Jira Software"
  type        = string
  default     = null
}

variable "jira_replica_count" {
  description = "Number of Jira application nodes"
  type        = number
  default     = 1
  validation {
    condition     = var.jira_replica_count >= 0
    error_message = "Number of nodes must be greater than or equal to 0."
  }
}

variable "jira_cpu" {
  description = "Number of CPUs for Jira instance"
  type        = string
  default     = "1"
}

variable "jira_mem" {
  description = "Amount of memory for Jira instance"
  type        = string
  default     = "2Gi"
}

variable "jira_min_heap" {
  description = "Minimum heap size for Jira instance"
  type        = string
  default     = "384m"
}

variable "jira_max_heap" {
  description = "Maximum heap size for Jira instance"
  type        = string
  default     = "768m"
}

variable "jira_reserved_code_cache" {
  description = "Reserved code cache for Jira instance"
  type        = string
  default     = "512m"
}

variable "jira_local_home_size" {
  description = "Storage size for Jira local home"
  type        = string
  default     = "10Gi"
}

variable "jira_db_major_engine_version" {
  description = "The database major version to use for Jira."
  default     = "12"
  type        = string
}

variable "jira_db_allocated_storage" {
  description = "Allocated storage for database instance in GiB."
  default     = 100
  type        = number
}

variable "jira_db_instance_class" {
  description = "Instance class of the RDS instance."
  default     = "db.t3.micro"
  type        = string
}

variable "jira_db_iops" {
  description = "The requested number of I/O operations per second that the DB instance can support."
  default     = 1000
  type        = number
}

variable "jira_db_snapshot_identifier" {
  description = "The identifier for the DB snapshot to restore from. The snapshot should be in the same AWS Region as the DB instance."
  default     = null
  type        = string
}

variable "jira_db_master_password" {
  description = "Master password for the Jira RDS instance."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^([aA-zZ]|[0-9]|[!@#$%^&*(){}?<>,.]).{8,}$", var.jira_db_master_password)) || var.jira_db_master_password == null
    error_message = "Master password must be set. It must be at least 8 characters long and contain combination of numbers, letters, and special characters."
  }
}

################################################################################
# Confluence variables
################################################################################

variable "confluence_license" {
  description = "Confluence license."
  type        = string
  sensitive   = true
  default     = null
}

variable "confluence_helm_chart_version" {
  description = "Version of confluence Helm chart"
  type        = string
  default     = "1.2.0"
}

variable "confluence_version_tag" {
  description = "Version tag for Confluence"
  type        = string
  default     = null
}

variable "confluence_replica_count" {
  description = "Number of Confluence application nodes"
  type        = number
  default     = 1
  validation {
    condition     = var.confluence_replica_count >= 0
    error_message = "Number of nodes must be greater than or equal to 0."
  }
}

variable "confluence_install_local_chart" {
  description = "If true installs Confluence using local Helm charts located in local_helm_charts_path"
  default     = false
  type        = bool
}

variable "confluence_cpu" {
  description = "Number of CPUs for confluence instance"
  type        = string
  default     = "1"
}

variable "confluence_mem" {
  description = "Amount of memory for confluence instance"
  type        = string
  default     = "1Gi"
}

variable "confluence_min_heap" {
  description = "Minimum heap size for confluence instance"
  type        = string
  default     = "256m"
}

variable "confluence_max_heap" {
  description = "Maximum heap size for confluence instance"
  type        = string
  default     = "512m"
}

variable "confluence_local_home_size" {
  description = "Storage size for Confluence local home"
  type        = string
  default     = "10Gi"
}

variable "confluence_db_major_engine_version" {
  description = "The database major version to use for Confluence."
  type        = string
  default     = "11"
}

variable "confluence_db_allocated_storage" {
  description = "Allocated storage for database instance in GiB."
  default     = 1000
  type        = number
}

variable "confluence_db_instance_class" {
  description = "Instance class of the RDS instance."
  default     = "db.t3.micro"
  type        = string
}

variable "confluence_db_iops" {
  description = "The requested number of I/O operations per second that the DB instance can support."
  default     = 1000
  type        = number
}

variable "confluence_collaborative_editing_enabled" {
  description = "If true, Collaborative editing service will be enabled."
  type        = bool
  default     = true
}

################################################################################
# Bitbucket Variables
################################################################################

variable "bitbucket_helm_chart_version" {
  description = "Version of Bitbucket Helm chart"
  type        = string
  default     = "1.2.0"
}

variable "bitbucket_version_tag" {
  description = "Version tag for Bitbucket"
  type        = string
  default     = null
}

variable "bitbucket_replica_count" {
  description = "Number of Bitbucket application nodes"
  type        = number
  default     = 1
  validation {
    condition     = var.bitbucket_replica_count >= 0
    error_message = "Number of nodes must be greater than or equal to 0."
  }
}

variable "bitbucket_license" {
  description = "Bitbucket license."
  type        = string
  sensitive   = true
  default     = null
}

variable "bitbucket_admin_username" {
  description = "Bitbucket system administrator username."
  type        = string
  default     = null
}

variable "bitbucket_admin_password" {
  description = "Bitbucket system administrator password."
  type        = string
  default     = null
  sensitive   = true
}

variable "bitbucket_admin_display_name" {
  description = "Bitbucket system administrator display name."
  type        = string
  default     = null
}

variable "bitbucket_admin_email_address" {
  description = "Bitbucket system administrator email address."
  type        = string
  default     = null
}

variable "bitbucket_db_major_engine_version" {
  description = "The database major version to use."
  default     = "13"
  type        = string
}

variable "bitbucket_db_allocated_storage" {
  description = "Allocated storage for database instance in GiB."
  default     = 100
  type        = number
}

variable "bitbucket_db_instance_class" {
  description = "Instance class of the RDS instance."
  default     = "db.t3.micro"
  type        = string
}

variable "bitbucket_db_iops" {
  description = "The requested number of I/O operations per second that the DB instance can support."
  default     = 1000
  type        = number
}

variable "bitbucket_display_name" {
  description = "The display name of Bitbucket instance"
  type        = string
  default     = null
}

variable "bitbucket_cpu" {
  description = "Number of CPUs for Bitbucket instance"
  type        = string
  default     = "1"
}

variable "bitbucket_mem" {
  description = "Amount of memory for Bitbucket instance"
  type        = string
  default     = "1Gi"
}

variable "bitbucket_min_heap" {
  description = "Minimum heap size for Bitbucket instance"
  type        = string
  default     = "256m"
}

variable "bitbucket_max_heap" {
  description = "Maximum heap size for Bitbucket instance"
  type        = string
  default     = "512m"
}

variable "bitbucket_local_home_size" {
  description = "Storage size for Bitbucket local home"
  type        = string
  default     = "10Gi"
}

variable "bitbucket_shared_home_size" {
  description = "Storage size for Bitbucket shared home"
  type        = string
  default     = "10Gi"
}

variable "bitbucket_nfs_requests_cpu" {
  description = "The minimum CPU compute to request for the NFS instance"
  type        = string
  default     = "0.25"
}

variable "bitbucket_nfs_requests_memory" {
  description = "The minimum amount of memory to allocate to the NFS instance"
  type        = string
  default     = "256Mi"
}

variable "bitbucket_nfs_limits_cpu" {
  description = "The maximum CPU compute to allocate to the NFS instance"
  type        = string
  default     = "0.25"
}

variable "bitbucket_nfs_limits_memory" {
  description = "The maximum amount of memory to allocate to the NFS instance"
  type        = string
  default     = "256Mi"
}

variable "bitbucket_elasticsearch_cpu" {
  description = "Number of CPUs for Bitbucket elasticsearch instance."
  type        = string
  default     = "0.25"
}

variable "bitbucket_elasticsearch_mem" {
  description = "Amount of memory for Bitbucket elasticsearch instance."
  type        = string
  default     = "1Gi"
}

variable "bitbucket_elasticsearch_storage" {
  description = "Storage size for Bitbucket elasticsearch in GiB."
  type        = number
  default     = 10
}

variable "bitbucket_elasticsearch_replicas" {
  description = "Number of nodes in Elasticsearch cluster"
  type        = number
  default     = 2
}

################################################################################
# Bamboo Variables
################################################################################

variable "bamboo_license" {
  description = "Bamboo license."
  type        = string
  sensitive   = true
  default     = null
}

variable "bamboo_admin_username" {
  description = "Bamboo system administrator username."
  type        = string
  default     = null
}

variable "bamboo_admin_password" {
  description = "Bamboo system administrator password."
  type        = string
  default     = null
  sensitive   = true
}

variable "bamboo_admin_display_name" {
  description = "Bamboo system administrator display name."
  type        = string
  default     = null
}

variable "bamboo_admin_email_address" {
  description = "Bamboo system administrator email address."
  type        = string
  default     = null
}

variable "number_of_bamboo_agents" {
  description = "Number of Bamboo remote agents."
  default     = 5
  type        = number
  validation {
    condition     = var.number_of_bamboo_agents >= 0
    error_message = "Number of agents must be greater than or equal to 0."
  }
}

variable "bamboo_helm_chart_version" {
  description = "Version of Bamboo Helm chart"
  default     = "1.2.0"
  type        = string
}

variable "bamboo_agent_helm_chart_version" {
  description = "Version of Bamboo agent Helm chart"
  type        = string
  default     = "1.2.0"
}

variable "bamboo_version_tag" {
  description = "Version tag for Bamboo"
  type        = string
  default     = null
}

variable "bamboo_agent_version_tag" {
  description = "Version tag for Bamboo Agent"
  type        = string
  default     = null
}

variable "bamboo_cpu" {
  description = "Number of CPUs for Bamboo instance"
  type        = string
  default     = "1"
}

variable "bamboo_mem" {
  description = "Amount of memory for Bamboo instance"
  type        = string
  default     = "1Gi"
}

variable "bamboo_min_heap" {
  description = "Minimum heap size for Bamboo instance"
  type        = string
  default     = "256m"
}

variable "bamboo_max_heap" {
  description = "Maximum heap size for Bamboo instance"
  type        = string
  default     = "512m"
}

variable "bamboo_agent_cpu" {
  description = "Number of CPUs for Bamboo agent instance"
  type        = string
  default     = "0.25"
}

variable "bamboo_agent_mem" {
  description = "Amount of memory for Bamboo agent instance"
  type        = string
  default     = "256m"
}

variable "bamboo_local_home_size" {
  description = "Storage size for Bamboo local home"
  type        = string
  default     = "10Gi"
}

variable "bamboo_install_local_chart" {
  description = "If true installs Bamboo and Agents using local Helm charts located in local_helm_charts_path"
  type        = bool
  default     = false
}

variable "bamboo_db_major_engine_version" {
  description = "The database major version to use for Bamboo."
  type        = string
  default     = "13"
}

variable "bamboo_db_allocated_storage" {
  description = "Allocated storage for database instance in GiB."
  default     = 100
  type        = number
}

variable "bamboo_db_instance_class" {
  description = "Instance class of the RDS instance."
  default     = "db.t3.micro"
  type        = string
}

variable "bamboo_db_iops" {
  description = "The requested number of I/O operations per second that the DB instance can support."
  default     = 1000
  type        = number
}

variable "bamboo_dataset_url" {
  description = "URL of the dataset to restore in the Bamboo instance"
  default     = null
  type        = string
}
