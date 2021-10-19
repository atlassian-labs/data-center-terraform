variable "region_name" {
  description = "Name of the AWS region"
  type = string
  validation {
    condition     = can(regex("(us(-gov)?|ap|af|ca|cn|eu|sa)-(central|(north|south)?(east|west)?)-[1-3]", var.region_name))
    error_message = "Invalid region."
  }
}

variable "cluster_name" {
  description = "Name of the associated cluster"
  type = string
  validation {
    condition     = can(regex("^([a-zA-Z])+(([a-zA-Z]|[0-9])*-?)*$", var.cluster_name))
    error_message = "Invalid cluster name."
  }
}

variable "required_tags" {
  description = "List of tags"
  type = map(any)
}

variable "vpc_name" {
  description = "Name of the VPC"
  type = string
  default = "dc-bamboo-vpc"
  validation {
    condition     = can(regex("^([a-zA-Z])+(([a-zA-Z]|[0-9])*-?)*$", var.vpc_name))
    error_message = "Invalid VPC name."
  }
}
