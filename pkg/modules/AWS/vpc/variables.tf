variable "vpc_name" {
  description = "Name of the VPC to create"
  type = string
  validation {
    condition     = can(regex("^([a-zA-Z])+(([a-zA-Z]|[0-9])*-?)*$", var.vpc_name))
    error_message = "Invalid vpc name."
  }
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

variable "vpc_private_subnets" {
  type        = list(string)
  default     = []
  description = "List of private subnets CIDR"
  validation {
    condition     = can([for ip in var.vpc_private_subnets : regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/([1-9]|1[0-9]|2[0-9]|3[0-1])$", ip)])
    error_message = "Invalid List of CIDR."
  }
}

variable "vpc_public_subnets" {
  type        = list(string)
  default     = []
  description = "List of public subnets CIDR"
  validation {
    condition     = can([for ip in var.vpc_public_subnets : regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/([1-9]|1[0-9]|2[0-9]|3[0-1])$", ip)])
    error_message = "Invalid List of CIDR."
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

variable enable_nat_gateway {
  description = "Enable NAT gateway."
  type = bool
  default = true
}

variable single_nat_gateway {
  description = "Enable single NAT gateway."
  type = bool
  default = true
}

variable enable_dns_hostnames {
  description = "Enable DNS hostnames."
  type = bool
  default = true
}
