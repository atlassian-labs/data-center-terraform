variable "vpc_name" {
  description = "Name of the VPC to create"
  type = string
}

variable "required_tags" {
  description = "List of tags"
  type = map(any)
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type = string
  default = "10.0.0.0/16"
  validation {
    condition     = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/([1-9]|1[0-9]|2[0-9]|3[0-1])$", var.vpc_cidr))
    error_message = "Invalid CIDR."
  }
}

variable vpc_azs {
  description = "List of availability zones."
  type = list
  default = []
  validation {
    condition     = can([for az in var.vpc_azs : regex("(us(-gov)?|ap|ca|cn|eu|sa)-(central|(north|south)?(east|west)?)-[1-9][a-z]", az)])
    error_message = "Invalid availability zones."
  }
}