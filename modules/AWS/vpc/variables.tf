variable "vpc_name" {
  description = "Name of the VPC to create"
  type        = string
  validation {
    condition     = can(regex("^([a-zA-Z])+(([a-zA-Z]|[0-9])*-?)*$", var.vpc_name))
    error_message = "Invalid vpc name."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC (IPv4 or IPv6)"
  type        = string
  default     = "10.0.0.0/18"
  validation {
    condition = (
      can(regex("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])/([1-9]|1[0-9]|2[0-4])$", var.vpc_cidr)) ||
      can(regex("^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}/([0-9]|[1-9][0-9]|1[0-1][0-9]|12[0-8])$", var.vpc_cidr))
    )
    error_message = "Invalid VPC CIDR block. Must be a valid IPv4 CIDR (e.g., 10.0.0.0/16) or IPv6 CIDR (e.g., 2001:db8::/32) with appropriate prefix length."
  }
}