variable "region_name" {
  description = "Name of the AWS region"
  type        = string
}

variable "environment_name" {
  description = "Name of the cluster"
  type        = string
  validation {
    condition     = can(regex("^([a-zA-Z])+(([a-zA-Z]|[0-9])*-?)*$", var.environment_name))
    error_message = "Invalid cluster name."
  }
}

variable "required_tags" {
  description = "List of required tags"
  type        = map(string)
}

variable "vpc" {
  description = "vpc module that hosts the product"
  type        = any
}

variable "eks" {
  description = "EKS module that hosts the product"
  type        = any
}

variable "efs" {
  description = "EFS module to provide shared-hole to the product"
  type        = any
}