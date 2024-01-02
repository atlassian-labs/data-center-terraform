variable "environment_name" {
  description = "Name of the environment."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9\\-]{1,24}$", var.environment_name))
    error_message = "Invalid environment name. Valid name is up to 25 characters starting with alphabet and followed by alphanumerics. '-' is allowed as well."
  }
}

variable "namespace" {
  description = "Kubernetes namespace to install confluence."
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
  description = "Number of Confluence application nodes"
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

variable "confluence_configuration" {
  description = "Confluence resource spec and chart version"
  type        = map(any)
  validation {
    condition = (length(var.confluence_configuration) == 7 &&
      alltrue([
        for o in keys(var.confluence_configuration) : contains([
          "helm_version", "cpu", "mem", "min_heap", "max_heap", "license", "custom_values_file"
        ], o)
    ]))
    error_message = "Confluence configuration is not valid."
  }
}

variable "synchrony_configuration" {
  description = "Synchrony resource spec"
  type        = map(any)
  validation {
    condition = (length(var.synchrony_configuration) == 5 &&
      alltrue([
        for o in keys(var.synchrony_configuration) : contains([
          "cpu", "mem", "min_heap", "max_heap", "stack_size"
        ], o)
    ]))
    error_message = "Synchrony configuration is not valid."
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

variable "version_tag" {
  description = "Version tag for Confluence"
  type        = string
  default     = null
}

variable "local_confluence_chart_path" {
  description = "Path to local Helm charts to install local confluence software"
  type        = string
  default     = ""
  validation {
    condition     = can(regex("^[.?\\/?[a-zA-Z0-9|\\-|_]*]*$", var.local_confluence_chart_path))
    error_message = "Invalid local confluence Helm chart path."
  }
}

variable "enable_synchrony" {
  description = "If true, Collaborative editing service will be enabled."
  type        = bool
}

variable "db_snapshot_id" {
  description = "Snapshot identifier for RDS."
  type        = string
  default     = null
}

variable "db_snapshot_build_number" {
  description = "Confluence build number of the database snapshot."
  type        = string
  default     = null
  validation {
    condition     = var.db_snapshot_build_number == null || can(regex("^[0-9]{4}$", var.db_snapshot_build_number))
    error_message = "Invalid build number. Valid build number will be a 4-digit string."
  }
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
}

variable "confluence_s3_attachments_storage" {
  description = "Use S3 as attachment storage"
  type        = bool
}

variable "region_name" {
  description = "Name of the AWS region"
  type        = string
}

variable "shared_home_pvc_name" {
  description = "Name of the shared-home PVC"
  type        = string
}
