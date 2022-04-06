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

variable "replica_count" {
  description = "Number of Jira application nodes"
  type        = number
}

variable "jira_configuration" {
  description = "Jira resource spec and chart version"
  type        = map(any)
  validation {
    condition = (length(var.jira_configuration) == 6 &&
    alltrue([for o in keys(var.jira_configuration) : contains(["helm_version", "cpu", "mem", "min_heap", "max_heap", "reserved_code_cache"], o)]))
    error_message = "Jira configuration is not valid."
  }
}

variable "local_home_size" {
  description = "The storage capacity to allocate to local home"
  type        = string
  default     = "10Gi"
}

variable "version_tag" {
  description = "Version of Jira Software"
  type        = string
  default     = null
}

variable "pvc_claim_name" {
  description = "Persistent volume claim name for shared home."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z]+[a-zA-Z0-9|\\-|_]*$", var.pvc_claim_name))
    error_message = "Invalid claim name."
  }
}

variable "db_snapshot_identifier" {
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