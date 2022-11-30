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

variable "eks_version" {
  description   = "EKS K8s version"
  default       = 1.24
  type          = number
  validation {
    condition     = can(regex("^1\\.2[1-4]", var.eks_version))
    error_message = "Invalid EKS K8S version. Valid versions are from 1.21 to 1.24"
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

variable "logging_bucket" {
  description = "S3 bucket to store logs."
  default     = null
  type        = string
  validation {
    condition     = var.logging_bucket == null || can(regex("^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", var.logging_bucket))
    error_message = "Invalid logging bucket name. Valid name is up to 63 characters starting with alphabet and followed by alphanumerics. '-' is allowed as well."
  }
}

variable "eks_additional_roles" {
  description = "Additional roles that have access to the cluster."
  default     = []
  type        = list(object({ rolearn = string, username = string, groups = list(string) }))
}

variable "whitelist_cidr" {
  description = "List of CIDRs allowed accessing the application(s)."
  default     = ["0.0.0.0/0"]
  type        = list(string)
  validation {
    condition = alltrue([
    for o in var.whitelist_cidr : can(regex("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])/([0-9]|1[0-9]|2[0-9]|3[0-2])$", o))])
    error_message = "Invalid whitelist CIDR. Valid format is a list of '<IPv4>/[0-32]' e.g: [\"10.0.0.0/18\"]."
  }
}

variable "enable_https_ingress" {
  description = "If true, Nginx controller will listen on 443 as well."
  type        = bool
  default     = true
}

################################################################################
# Jira Settings
################################################################################

variable "jira_helm_chart_version" {
  description = "Version of Jira Helm chart"
  type        = string
  default     = ""
}

variable "jira_image_repository" {
  description = "Jira image repository"
  type        = string
  default     = "atlassian/jira-software"
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

variable "jira_termination_grace_period" {
  description = "Termination grace period in seconds"
  type        = number
  default     = 30
}

variable "jira_installation_timeout" {
  description = "Timeout for helm chart installation in minutes"
  type        = number
  default     = 15
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

variable "jira_db_name" {
  description = "The default DB name of the DB instance."
  default     = "jira"
  type        = string
}

variable "jira_db_snapshot_id" {
  description = "The identifier for the DB snapshot to restore from. The snapshot should be in the same AWS region as the DB instance."
  default     = null
  type        = string
}

variable "jira_license" {
  description = "Jira license."
  type        = string
  sensitive   = true
  default     = ""
}


variable "jira_db_master_username" {
  description = "Master username for the Jira RDS instance."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^[a-zA-Z_]([a-zA-Z0-9_]).{5,30}$", var.jira_db_master_username)) || var.jira_db_master_username == null
    error_message = "Master username must be set. It must be between 6 and 31 characters long and start with a letter/underscore and contain combination of numbers, letters, and underscore."
  }
}

variable "jira_db_master_password" {
  description = "Master password for the Jira RDS instance."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^([aA-zZ]|[0-9]|[!#$%^&*(){}?<>,.]).{8,}$", var.jira_db_master_password)) || var.jira_db_master_password == null
    error_message = "Master password must be set. It must be at least 8 characters long and contain combination of numbers, letters, and special characters."
  }
}

variable "jira_shared_home_size" {
  description = "Storage size for Jira shared home"
  type        = string
  default     = "10Gi"
}

variable "jira_nfs_requests_cpu" {
  description = "The minimum CPU compute to request for the NFS instance"
  type        = string
  default     = "1"
}

variable "jira_nfs_requests_memory" {
  description = "The minimum amount of memory to allocate to the NFS instance"
  type        = string
  default     = "1Gi"
}

variable "jira_nfs_limits_cpu" {
  description = "The maximum CPU compute to allocate to the NFS instance"
  type        = string
  default     = "2"
}

variable "jira_nfs_limits_memory" {
  description = "The maximum amount of memory to allocate to the NFS instance"
  type        = string
  default     = "2Gi"
}

variable "jira_shared_home_snapshot_id" {
  description = "EBS Snapshot ID with shared home content."
  type        = string
  default     = null
  validation {
    condition     = var.jira_shared_home_snapshot_id == null || can(regex("^snap-\\w{17}$", var.jira_shared_home_snapshot_id))
    error_message = "Provide correct EBS snapshot ID."
  }
}

variable "jira_install_local_chart" {
  description = "If true installs Jira using local Helm charts located in local_helm_charts_path"
  default     = false
  type        = bool
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
  default     = ""
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

variable "confluence_termination_grace_period" {
  description = "Termination grace period in seconds"
  type        = number
  default     = 30
}

variable "confluence_installation_timeout" {
  description = "Timeout for helm chart installation in minutes"
  type        = number
  default     = 15
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
  validation {
    condition     = can(regex("^([0-9]){1,5}[k|m|g]$", var.confluence_min_heap))
    error_message = "Minimum heap size for confluence instance is invalid. (Correct form: 1g | 1024m | 2048k)"
  }
}

variable "confluence_max_heap" {
  description = "Maximum heap size for confluence instance"
  type        = string
  default     = "512m"
  validation {
    condition     = can(regex("^([0-9]){1,5}[k|m|g]$", var.confluence_max_heap))
    error_message = "Maximum heap size for confluence instance is invalid. (Correct form: 1g | 1024m | 2048k)"
  }
}

variable "synchrony_cpu" {
  description = "Number of CPUs for synchrony instance"
  type        = string
  default     = "2"
}

variable "synchrony_mem" {
  description = "Amount of memory for synchrony instance"
  type        = string
  default     = "2.5Gi"
}

variable "synchrony_min_heap" {
  description = "Minimum heap size for synchrony instance"
  type        = string
  default     = "1g"
  validation {
    condition     = can(regex("^([0-9]){1,5}[k|m|g]$", var.synchrony_min_heap))
    error_message = "Minimum heap size for synchrony instance is invalid. (Correct form: 1g | 1024m | 2048k)"
  }
}

variable "synchrony_max_heap" {
  description = "Maximum heap size for synchrony instance"
  type        = string
  default     = "2g"
  validation {
    condition     = can(regex("^([0-9]){1,5}[k|m|g]$", var.synchrony_max_heap))
    error_message = "Maximum heap size for synchrony instance is invalid. (Correct form: 1g | 1024m | 2048k)"
  }
}

variable "synchrony_stack_size" {
  description = "Stack size for synchrony instance"
  type        = string
  default     = "2048k"
  validation {
    condition     = can(regex("^([0-9]){1,4}[k|m]$", var.synchrony_stack_size))
    error_message = "Stack size for synchrony instance is invalid. (Correct form: 64m | 2048k)"
  }
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

variable "confluence_db_name" {
  description = "The default DB name of the DB instance."
  default     = "confluence"
  type        = string
}

variable "confluence_collaborative_editing_enabled" {
  description = "If true, Collaborative editing service will be enabled."
  type        = bool
  default     = true
}

variable "confluence_db_snapshot_id" {
  description = "The identifier for the Confluence DB snapshot to restore from."
  default     = null
  type        = string
}

variable "confluence_db_snapshot_build_number" {
  description = "Confluence build number of the database snapshot."
  type        = string
  default     = null
}

variable "confluence_db_master_username" {
  description = "Master username for the Confluence RDS instance."
  type        = string
  default     = null
}

variable "confluence_db_master_password" {
  description = "Master password for the Confluence RDS instance."
  type        = string
  default     = null
}

variable "confluence_shared_home_size" {
  description = "Storage size for Confluence shared home"
  type        = string
  default     = "10Gi"
}

variable "confluence_nfs_requests_cpu" {
  description = "The minimum CPU compute to request for the NFS instance"
  type        = string
  default     = "1"
}

variable "confluence_nfs_requests_memory" {
  description = "The minimum amount of memory to allocate to the NFS instance"
  type        = string
  default     = "1Gi"
}

variable "confluence_nfs_limits_cpu" {
  description = "The maximum CPU compute to allocate to the NFS instance"
  type        = string
  default     = "2"
}

variable "confluence_nfs_limits_memory" {
  description = "The maximum amount of memory to allocate to the NFS instance"
  type        = string
  default     = "2Gi"
}

variable "confluence_shared_home_snapshot_id" {
  description = "EBS Snapshot ID with shared home content."
  type        = string
  default     = null
}

################################################################################
# Bitbucket Variables
################################################################################

variable "bitbucket_helm_chart_version" {
  description = "Version of Bitbucket Helm chart"
  type        = string
  default     = ""
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

variable "bitbucket_termination_grace_period" {
  description = "Termination grace period in seconds"
  type        = number
  default     = 30
}

variable "bitbucket_installation_timeout" {
  description = "Timeout for helm chart installation in minutes"
  type        = number
  default     = 15
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

variable "bitbucket_db_name" {
  description = "The default DB name of the DB instance."
  default     = "bitbucket"
  type        = string
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
  default     = "1"
}

variable "bitbucket_nfs_requests_memory" {
  description = "The minimum amount of memory to allocate to the NFS instance"
  type        = string
  default     = "1Gi"
}

variable "bitbucket_nfs_limits_cpu" {
  description = "The maximum CPU compute to allocate to the NFS instance"
  type        = string
  default     = "2"
}

variable "bitbucket_nfs_limits_memory" {
  description = "The maximum amount of memory to allocate to the NFS instance"
  type        = string
  default     = "2Gi"
}

variable "bitbucket_elasticsearch_requests_cpu" {
  description = "Number of CPUs for Bitbucket elasticsearch instance."
  type        = string
  default     = "0.25"
}

variable "bitbucket_elasticsearch_requests_memory" {
  description = "Amount of memory for Bitbucket elasticsearch instance."
  type        = string
  default     = "1Gi"
}

variable "bitbucket_elasticsearch_limits_cpu" {
  description = "CPUs limit for elasticsearch instance."
  type        = string
  default     = "0.5"
}

variable "bitbucket_elasticsearch_limits_memory" {
  description = "Memory limit for elasticsearch instance."
  type        = string
  default     = "2Gi"
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

variable "bitbucket_shared_home_snapshot_id" {
  description = "EBS Snapshot ID with shared home content."
  type        = string
  default     = null
}

variable "bitbucket_db_snapshot_id" {
  description = "The identifier for the DB snapshot to restore from. The snapshot should be in the same AWS region as the DB instance."
  default     = null
  type        = string
}

variable "bitbucket_db_master_username" {
  description = "Master username for the Bitbucket RDS instance."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^[a-zA-Z_]([a-zA-Z0-9_]).{5,30}$", var.bitbucket_db_master_username)) || var.bitbucket_db_master_username == null
    error_message = "Master username must be set. It must be between 6 and 31 characters long and start with a letter/underscore and contain combination of numbers, letters, and underscore."
  }
}

variable "bitbucket_db_master_password" {
  description = "Master password for the Bitbucket RDS instance."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^([aA-zZ]|[0-9]|[!#$%^&*(){}?<>,.]).{8,}$", var.bitbucket_db_master_password)) || var.bitbucket_db_master_password == null
    error_message = "Master password must be set. It must be at least 8 characters long and contain combination of numbers, letters, and special characters."
  }
}

variable "bitbucket_install_local_chart" {
  description = "If true installs Bitbucket using local Helm charts located in local_helm_charts_path"
  default     = false
  type        = bool
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
  default     = ""
  type        = string
}

variable "bamboo_agent_helm_chart_version" {
  description = "Version of Bamboo agent Helm chart"
  type        = string
  default     = ""
}

variable "bamboo_version_tag" {
  description = "Version tag for Bamboo"
  type        = string
  default     = null
}

variable "bamboo_installation_timeout" {
  description = "Timeout for helm chart installation in minutes"
  type        = number
  default     = 15
}

variable "bamboo_termination_grace_period" {
  description = "Termination grace period in seconds"
  type        = number
  default     = 30
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

variable "bamboo_shared_home_size" {
  description = "Storage size for Bamboo shared home"
  type        = string
  default     = "10Gi"
}

variable "bamboo_nfs_requests_cpu" {
  description = "The minimum CPU compute to request for the NFS instance"
  type        = string
  default     = "1"
}

variable "bamboo_nfs_requests_memory" {
  description = "The minimum amount of memory to allocate to the NFS instance"
  type        = string
  default     = "1Gi"
}

variable "bamboo_nfs_limits_cpu" {
  description = "The maximum CPU compute to allocate to the NFS instance"
  type        = string
  default     = "2"
}

variable "bamboo_nfs_limits_memory" {
  description = "The maximum amount of memory to allocate to the NFS instance"
  type        = string
  default     = "2Gi"
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

variable "bamboo_db_name" {
  description = "The default DB name of the DB instance."
  default     = "bamboo"
  type        = string
}

variable "bamboo_dataset_url" {
  description = "URL of the dataset to restore in the Bamboo instance"
  default     = null
  type        = string
}

variable "osquery_fleet_enrollment_secret_name" {
  type = string
  description = "Fleet enrollment secret name"
  default = ""
}

variable "osquery_fleet_enrollment_secret_region_aws" {
  description = "Fleet enrollment secret AWS region"
  type    = string
  default = ""
}

variable "osquery_env" {
  type = string
  description = "Osquery environment name"
  default = "osquery_dc_e2e_tests"
}

variable "osquery_version" {
  description = "Osquery version"
  type        = string
  default     = "5.4.0"
}

variable "kinesis_log_producers_role_arns" {
  description = "AWS kinesis log producer role"
  type   = object({
    eu     = string
    non-eu = string
  })
  default = {
    eu     = "dummy-arn",
    non-eu = "dummy-arn"
  }
}
