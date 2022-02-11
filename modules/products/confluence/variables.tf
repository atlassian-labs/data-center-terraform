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

variable "ingress" {
  default = null
  type    = any
}

variable "db_major_engine_version" {
  description = "The Database major version to use."
  type        = string
}

variable "db_configuration" {
  description = "Confluence database spec"
  type        = map(any)
  validation {
    condition = (length(var.db_configuration) == 3 &&
      alltrue([
        for o in keys(var.db_configuration) : contains([
          "db_allocated_storage", "db_instance_class", "db_iops"
        ], o)
    ]))
    error_message = "Confluence database configuration is not valid."
  }
}

variable "confluence_configuration" {
  description = "Confluence resource spec and chart version"
  type        = map(any)
  validation {
    condition = (length(var.confluence_configuration) == 6 &&
      alltrue([
        for o in keys(var.confluence_configuration) : contains([
          "helm_version", "cpu", "mem", "min_heap", "max_heap", "license"
        ], o)
    ]))
    error_message = "Confluence configuration is not valid."
  }
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

variable "pvc_claim_name" {
  description = "Persistent volume claim name for shared home."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z]+[a-zA-Z0-9|\\-|_]*$", var.pvc_claim_name))
    error_message = "Invalid claim name."
  }
}

variable "enable_synchrony" {
  description = "If true, Collaborative editing service will be enabled."
  type        = bool
}