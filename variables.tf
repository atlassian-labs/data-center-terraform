# To customise the infrastructure you must provide the value for each of these parameters in config.tfvar

variable "region" {
  description = "Name of the AWS region."
  type        = string
}

variable "environment_name" {
  description = "Name for this environment that is going to be deployed. The value will be used to form the name of some resources."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9\\-]{1,63}$", var.environment_name))
    error_message = "Invalid environment name."
  }
}

variable "resource_tags" {
  description = "Additional tags for all resources to be created."
  type        = map(string)
}

variable "instance_types" {
  description = "Instance types that is preferred for node group."
  type        = list(string)
}

variable "desired_capacity" {
  description = "Desired number of nodes that the node group should launch with initially."
  type        = number
}

