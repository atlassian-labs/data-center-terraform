variable "vpc_name" {
  description = "Name of the VPC to create"
  type        = string
  validation {
    condition     = can(regex("^([a-zA-Z])+(([a-zA-Z]|[0-9])*-?)*$", var.vpc_name))
    error_message = "Invalid vpc name."
  }
}

variable "vpc_tags" {
  description = "List of tags"
  type        = map(string)
}
