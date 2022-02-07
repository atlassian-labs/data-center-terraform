variable "region_name" {
  description = "Name of the AWS region."
  type        = string
}

variable "environment_name" {
  description = "Name of the environment."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9\\-]{1,24}$", var.environment_name))
    error_message = "Invalid environment name. Valid name is up to 25 characters starting with alphabet and followed by alphanumerics. '-' is allowed as well."
  }
}

variable "vpc" {
  description = "vpc module that hosts the product."
  type        = any
}

variable "eks" {
  description = "EKS module that hosts the product."
  type        = any
}

variable "efs" {
  description = "EFS module to provide shared-home to the product."
  type        = any
}

variable "ingress" {
  default = null
  type    = any
}

variable "share_home_size" {
  description = "Shared home persistent volume size."
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

variable "license" {
  description = "Bamboo license."
  type        = string
  sensitive   = true
}

variable "admin_username" {
  description = "System administrator username."
  type        = string
}

variable "admin_password" {
  description = "System administrator password."
  type        = string
  sensitive   = true
}

variable "admin_display_name" {
  description = "System administrator display name."
  type        = string
}

variable "admin_email_address" {
  description = "System administrator email address."
  type        = string
}

variable "dataset_url" {
  description = "URL of the dataset to restore in the Bamboo instance"
  type        = string
}

variable "bamboo_configuration" {
  description = "Bamboo resource spec and chart version"
  type        = map(any)
  validation {
    condition = (length(var.bamboo_configuration) == 5 &&
    alltrue([for o in keys(var.bamboo_configuration) : contains(["helm_version", "cpu", "mem", "min_heap", "max_heap"], o)]))
    error_message = "Bamboo configuration is not valid1."
  }
}

variable "bamboo_agent_configuration" {
  description = "Bamboo agent resource spec and chart version"
  type        = map(any)
  validation {
    condition = (length(var.bamboo_agent_configuration) == 4 &&
    alltrue([for o in keys(var.bamboo_agent_configuration) : contains(["helm_version", "cpu", "mem", "agent_count"], o)]))
    error_message = "Bamboo Agent configuration is not valid."
  }
}

variable "local_bamboo_chart_path" {
  description = "Path to local Helm charts to install local Bamboo software"
  type = string
  validation {
    condition     = can(regex("^[.?\\/?[a-zA-Z0-9|\\-|_]*]*$", var.local_bamboo_chart_path))
    error_message = "Invalid local Bamboo Helm chart path."
  }
  default = ""
}

variable "local_agent_chart_path" {
  description = "Path to local Helm charts to install local Bamboo Agents"
  type = string
  validation {
    condition     = can(regex("^[.?\\/?[a-zA-Z0-9|\\-|_]*]*$", var.local_agent_chart_path))
    error_message = "Invalid local Bamboo Agent Helm chart path."
  }
  default = ""
}

