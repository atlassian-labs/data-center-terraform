variable "environment_name" {
  description = "Name of the environment."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9\\-]{1,24}$", var.environment_name))
    error_message = "Invalid environment name. Valid name is up to 25 characters starting with alphabet and followed by alphanumerics. '-' is allowed as well."
  }
}

variable "namespace" {
  description = "The namespace where Jira pod will be installed."
  type        = string
}

variable "vpc" {
  description = "VPC module that hosts the products."
  type        = any
}

variable "eks" {
  description = "EKS module that hosts the product."
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
  description = "Number of Jira application nodes"
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

variable "local_jira_chart_path" {
  description = "Path to local Helm charts to install local Jira software"
  type        = string
  default     = ""
  validation {
    condition     = can(regex("^[.?\\/?[a-zA-Z0-9|\\-|_]*]*$", var.local_jira_chart_path))
    error_message = "Invalid local Jira Helm chart path."
  }
}

variable "jira_configuration" {
  description = "Jira resource spec and chart version"
  type        = map(any)
  validation {
    condition = (length(var.jira_configuration) == 8 &&
    alltrue([for o in keys(var.jira_configuration) : contains(["helm_version", "cpu", "mem", "min_heap", "max_heap", "reserved_code_cache", "license", "custom_values_file"], o)]))
    error_message = "Jira configuration is not valid."
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

variable "shared_home_snapshot_id" {
  description = "EBS Snapshot ID with shared home content."
  type        = string
  default     = null
  validation {
    condition     = var.shared_home_snapshot_id == null || can(regex("^snap-\\w{17}$", var.shared_home_snapshot_id))
    error_message = "Provide correct EBS snapshot ID."
  }
}

variable "local_home_snapshot_id" {
  description = "EBS Snapshot ID with local home content."
  type        = string
  default     = null
  validation {
    condition     = var.local_home_snapshot_id == null || can(regex("^snap-\\w{17}$", var.local_home_snapshot_id))
    error_message = "Provide correct EBS snapshot ID."
  }
}

variable "image_repository" {
  description = "Jira image repository"
  type        = string
  default     = "atlassian/jira-software"
}

variable "version_tag" {
  description = "Version of Jira Software"
  type        = string
  default     = null
}

variable "db_snapshot_id" {
  description = "Snapshot identifier for RDS. The snapshot should be in the same AWS region as the DB instance."
  type        = string
  default     = null
}

variable "shared_home_pvc_name" {
  description = "Name of the shared-home PVC"
  type        = string
  default     = "jira-shared-home-pvc"
}
