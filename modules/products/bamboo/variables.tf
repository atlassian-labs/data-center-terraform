variable "environment_name" {
  description = "Name of the environment."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9\\-]{1,24}$", var.environment_name))
    error_message = "Invalid environment name. Valid name is up to 25 characters starting with alphabet and followed by alphanumerics. '-' is allowed as well."
  }
}

variable "namespace" {
  description = "Kubernetes namespace to install Bamboo."
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

variable "dataset_url" {
  description = "URL of the dataset to restore in the Bamboo instance"
  type        = string
}

variable "installation_timeout" {
  description = "Timeout for helm chart installation in minutes"
  type        = number
  validation {
    condition     = var.installation_timeout > 0
    error_message = "Installation timeout needs to be a positive number."
  }
}

variable "termination_grace_period" {
  description = "Termination grace period in seconds"
  type        = number
  validation {
    condition     = var.termination_grace_period >= 0
    error_message = "Termination grace period needs to be a positive number."
  }
}

variable "bamboo_configuration" {
  description = "Bamboo resource spec and chart version"
  type        = map(any)
  validation {
    condition = (length(var.bamboo_configuration) == 6 &&
    alltrue([for o in keys(var.bamboo_configuration) : contains(["helm_version", "cpu", "mem", "min_heap", "max_heap", "custom_values_file"], o)]))
    error_message = "Bamboo configuration is not valid."
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

variable "license" {
  description = "License to use for Bamboo"
  type        = string
  sensitive   = true
  validation {
    condition     = var.license != null && var.license != ""
    error_message = "License is not valid."
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

variable "version_tag" {
  description = "Version tag for Bamboo"
  type        = string
  default     = null
}

variable "agent_version_tag" {
  description = "Version tag for Bamboo Agent"
  type        = string
  default     = null
}

variable "local_bamboo_chart_path" {
  description = "Path to local Helm charts to install local Bamboo software"
  type        = string
  validation {
    condition     = can(regex("^[.?\\/?[a-zA-Z0-9|\\-|_]*]*$", var.local_bamboo_chart_path))
    error_message = "Invalid local Bamboo Helm chart path."
  }
  default = ""
}

variable "local_agent_chart_path" {
  description = "Path to local Helm charts to install local Bamboo Agents"
  type        = string
  validation {
    condition     = can(regex("^[.?\\/?[a-zA-Z0-9|\\-|_]*]*$", var.local_agent_chart_path))
    error_message = "Invalid local Bamboo Agent Helm chart path."
  }
  default = ""
}

variable "admin_username" {
  description = "Bamboo system administrator username."
  type        = string
}

variable "admin_password" {
  description = "Bamboo system administrator password."
  type        = string
  default     = null
}

variable "admin_display_name" {
  description = "Bamboo system administrator display name."
  type        = string
}

variable "admin_email_address" {
  description = "Bamboo system administrator email address."
  type        = string
  validation {
    condition     = can(regex("^([\\w\\.\\-]+)@([\\w\\-]+)((\\.(\\w){2,3})+)$", var.admin_email_address))
    error_message = "Invalid email."
  }
}

variable "shared_home_pvc_name" {
  description = "Name of the shared-home PVC"
  type        = string
}
