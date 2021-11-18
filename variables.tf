# To customise the infrastructure you must provide the value for each of these parameters in config.tfvar

variable "region" {
  description = "Name of the AWS region."
  type        = string
  validation {
    condition     = can(regex("(us(-gov)?|ap|ca|cn|eu|sa)-(central|(north|south)?(east|west)?)-[1-9]", var.region))
    error_message = "Invalid region name. Must be a valid AWS region."
  }
}

variable "environment_name" {
  description = "Name for this environment that is going to be deployed. The value will be used to form the name of some resources."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9\\-]{1,31}$", var.environment_name))
    error_message = "Invalid environment name. Valid name is up to 32 characters starting with alphabet and followed by alphanumerics. '-' is allowed as well."
  }
}

variable "resource_tags" {
  description = "Additional tags for all resources to be created."
  type        = map(string)
  default = {
    Terraform = "true"
  }
}

variable "instance_types" {
  description = "Instance types that is preferred for node group."
  type        = list(string)
  default     = ["m5.xlarge"]
}

variable "desired_capacity" {
  description = "Desired number of nodes that the node group should launch with initially."
  type        = number
  validation {
    condition     = var.desired_capacity > 0 && var.desired_capacity <= 10
    error_message = "Desired cluster capacity must be between 1 and 10 (included)."
  }
  default = 1
}

variable "domain" {
  description = "Domain name base for the ingress controller. The final domain is subdomain within this domain. (eg.: environment.domain.com)"
  type        = string
}

