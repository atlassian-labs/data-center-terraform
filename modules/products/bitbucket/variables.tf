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

variable "bitbucket_configuration" {
  description = "Bitbucket resource spec and chart version"
  type        = map(any)
  validation {
    condition = (length(var.bitbucket_configuration) == 6 &&
    alltrue([for o in keys(var.bitbucket_configuration) : contains(["helm_version", "cpu", "mem", "min_heap", "max_heap", "license"], o)]))
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

variable "nfs_requests_cpu" {
  description = "The minimum CPU compute to request for the NFS instance"
  type        = string
  default     = "0.25"
}

variable "nfs_requests_memory" {
  description = "The minimum amount of memory to allocate to the NFS instance"
  type        = string
  default     = "256Mi"
}

variable "nfs_limits_cpu" {
  description = "The maximum CPU compute to allocate to the NFS instance"
  type        = string
  default     = "0.25"
}

variable "nfs_limits_memory" {
  description = "The maximum amount of memory to allocate to the NFS instance"
  type        = string
  default     = "256Mi"
}

# If an external elasticsearch is not provided, Bitbucket will provision an elasticsearch cluster in k8s
variable "elasticsearch_endpoint" {
  description = "The external elasticsearch endpoint to be use by Bitbucket."
  type        = string
  default     = null
}

variable "elasticsearch_cpu" {
  description = "Number of CPUs for elasticsearch instance."
  type        = string
}

variable "elasticsearch_mem" {
  description = "Amount of memory for elasticsearch instance."
  type        = string
}

variable "elasticsearch_storage" {
  description = "Storage size for elasticsearch instance in Gib."
  type        = number
}

variable "elasticsearch_replicas" {
  description = "Number of nodes for elasticsearch instance."
  type        = number
  validation {
    condition     = can(regex("^[2-8]$", var.elasticsearch_replicas))
    error_message = "Invalid elasticsearch replicas. Valid replicas is a positive integer in range of [2,8]."
  }
}

variable "display_name" {
  description = "The display name of Bitbucket instance."
  type        = string
  default     = null
  validation {
    condition     = var.display_name == null || can(length(var.display_name) > 0 && length(var.display_name) < 255)
    error_message = "Bitbucket display name must be a non-empty value less than 255 characters."
  }
}