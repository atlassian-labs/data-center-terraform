variable "vpc_name" {
  description = "Name of the VPC to create"
  type        = string
  validation {
    condition     = can(regex("^([a-zA-Z])+(([a-zA-Z]|[0-9])*-?)*$", var.vpc_name))
    error_message = "Invalid vpc name."
  }
}

variable "vpc_cidr" {
  description = "Cidr block for vpc"
  type        = string
  default     = "10.0.0.0/18"
  validation {
    condition     = can(regex("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])/([1-9]|1[0-9]|2[0-4])$", var.vpc_cidr))
    error_message = "Invalid CIDR. Valid format is '<IPv4>/[1-24]' e.g: 10.0.0.0/18."
  }
}