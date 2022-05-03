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

variable "ingress" {
  default = null
  type    = any
}

variable "db_major_engine_version" {
  description = "The database major version to use."
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage for database instance in GiB."
  type        = number
}

variable "db_instance_class" {
  description = "Instance class of the RDS instance."
  type        = string
}

variable "db_iops" {
  description = "The requested number of I/O operations per second that the DB instance can support."
  type        = number
}

variable "db_name" {
  description = "The default DB name of the DB instance."
  type        = string
}

variable "replica_count" {
  description = "Number of Jira application nodes"
  type        = number
}

variable "installation_timeout" {
  description = "Timeout for helm chart installation in minutes"
  type        = number
  validation {
    condition     = var.installation_timeout > 0
    error_message = "Installation timeout needs to be a positive number."
  }
}

variable "jira_configuration" {
  description = "Jira resource spec and chart version"
  type        = map(any)
  validation {
    condition = (length(var.jira_configuration) == 7 &&
    alltrue([for o in keys(var.jira_configuration) : contains(["helm_version", "cpu", "mem", "min_heap", "max_heap", "reserved_code_cache", "license"], o)]))
    error_message = "Jira configuration is not valid."
  }
}

variable "nfs_requests_cpu" {
  description = "The minimum CPU compute to request for the NFS instance"
  type        = string
  default     = "1"
}

variable "nfs_requests_memory" {
  description = "The minimum amount of memory to allocate to the NFS instance"
  type        = string
  default     = "1Gi"
}

variable "nfs_limits_cpu" {
  description = "The maximum CPU compute to allocate to the NFS instance"
  type        = string
  default     = "2"
}

variable "nfs_limits_memory" {
  description = "The maximum amount of memory to allocate to the NFS instance"
  type        = string
  default     = "2Gi"
}

variable "local_home_size" {
  description = "The storage capacity to allocate to local home"
  type        = string
  default     = "10Gi"
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

variable "db_master_username" {
  description = "Master username for the RDS instance."
  type        = string
  default     = null
}


variable "db_master_password" {
  description = "Master password for the RDS instance."
  type        = string
  default     = null
}