variable "environment_name" {
  description = "Name of the environment."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9\\-]{1,24}$", var.environment_name))
    error_message = "Invalid environment name. Valid name is up to 25 characters starting with alphabet and followed by alphanumerics. '-' is allowed as well."
  }
}

variable "namespace" {
  description = "The namespace where Bitbucket Helm chart will be installed."
  type        = string
}

variable "vpc" {
  description = "VPC module that hosts the products."
  type        = any
}

variable "eks" {
  description = "EKS module that hosts the products."
  type        = any
}

variable "rds" {
  description = "RDS module that hosts the product."
  type        = any
}

variable "ingress" {
  default = null
  type    = any
}

variable "replica_count" {
  description = "Number of Bitbucket application nodes"
  type        = number
}

variable "termination_grace_period" {
  description = "Termination grace period in seconds"
  type        = number
  validation {
    condition     = var.termination_grace_period >= 0
    error_message = "Termination grace period needs to be a positive number."
  }
}

variable "installation_timeout" {
  description = "Timeout for helm chart installation in minutes"
  type        = number
  validation {
    condition     = var.installation_timeout > 0
    error_message = "Installation timeout needs to be a positive number."
  }
}

variable "local_bitbucket_chart_path" {
  description = "Path to local Helm charts to install local bitbucket software"
  type        = string
  default     = ""
  validation {
    condition     = can(regex("^[.?\\/?[a-zA-Z0-9|\\-|_]*]*$", var.local_bitbucket_chart_path))
    error_message = "Invalid local Bitbucket Helm chart path."
  }
}

variable "bitbucket_configuration" {
  description = "Bitbucket resource spec and chart version"
  type        = map(any)
  validation {
    condition = (length(var.bitbucket_configuration) == 7 &&
    alltrue([for o in keys(var.bitbucket_configuration) : contains(["helm_version", "cpu", "mem", "min_heap", "max_heap", "license", "custom_values_file"], o)]))
    error_message = "Bitbucket configuration is not valid."
  }
}

variable "version_tag" {
  description = "Version tag for Bitbucket"
  type        = string
  default     = null
}

variable "admin_configuration" {
  description = "Bitbucket admin configuration"
  type        = map(any)
  validation {
    condition = (length(var.admin_configuration) == 4 &&
    alltrue([for o in keys(var.admin_configuration) : contains(["admin_username", "admin_password", "admin_display_name", "admin_email_address"], o)]))
    error_message = "Bitbucket administrator configuration is not valid."
  }
}

variable "local_home_size" {
  description = "The storage capacity to allocate to local home"
  type        = string
  default     = "10Gi"
}

variable "local_home_retention_policy_when_deleted" {
  description = "Retention policy for local home when deleted."
  type        = string
  default     = "Delete"
}

variable "local_home_retention_policy_when_scaled" {
  description = "Retention policy for local home when scaled."
  type        = string
  default     = "Retain"
}

variable "shared_home_size" {
  description = "The storage capacity to allocate to the NFS"
  type        = string
  default     = "10Gi"
}

variable "deploy_opensearch" {
  description = "Install OpenSearch sub-chart with Bitbucket Helm chart"
  type        = bool
  default     = true
}

# If an external opensearch is not provided, Bitbucket will provision an opensearch cluster in k8s
variable "opensearch_endpoint" {
  description = "The external opensearch endpoint to be use by Bitbucket."
  type        = string
  default     = null
}

variable "opensearch_secret_name" {
  description = "Secret name with OpenSearch credentials."
  type        = string
  default     = null
}

variable "opensearch_secret_username_key" {
  description = "Username key in the opensearch secret"
  type        = string
}

variable "opensearch_secret_password_key" {
  description = "Password key in the opensearch secret"
  type        = string
}

variable "opensearch_requests_cpu" {
  description = "Number of CPUs requested for opensearch instance."
  type        = string
}

variable "opensearch_requests_memory" {
  description = "Amount of memory requested for opensearch instance."
  type        = string
}

variable "opensearch_limits_cpu" {
  description = "CPU limit for opensearch instance."
  type        = string
}

variable "opensearch_limits_memory" {
  description = "Memory limit for opensearch instance."
  type        = string
}

variable "opensearch_java_opts" {
  description = "JAVA_OPTS passed to OpenSearch JVM."
  type        = string
}

variable "opensearch_storage" {
  description = "Storage size for opensearch instance in Gib."
  type        = number
}

variable "opensearch_replicas" {
  description = "Number of nodes for opensearch instance."
  type        = number
  validation {
    condition     = can(regex("^[1-8]$", var.opensearch_replicas))
    error_message = "Invalid opensearch replicas. Valid replicas is a positive integer in range of [2,8]."
  }
}

variable "display_name" {
  description = "The display name of Bitbucket instance."
  type        = string
  default     = null
  validation {
    condition     = var.display_name == null || can(regex("^.{1,255}$", var.display_name))
    error_message = "Bitbucket display name must be a non-empty value less than 255 characters."
  }
}

variable "db_snapshot_id" {
  description = "Snapshot identifier for RDS. The snapshot should be in the same AWS region as the DB instance."
  type        = string
  default     = null
}

variable "shared_home_snapshot_id" {
  description = "EBS Snapshot ID with shared home content."
  type        = string
  default     = null
}

variable "shared_home_pvc_name" {
  description = "Name of the shared-home PVC"
  type        = string
  default     = "bitbucket-shared-home-pvc"

}

variable "additional_jvm_args" {
  description = "List of additional JVM arguments to be passed to the server"
  type        = list(string)
}
