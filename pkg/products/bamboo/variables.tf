variable "region_name" {
  description = "Name of the AWS region"
  type = string
}

variable "cluster_name" {
  description = "Name of the cluster"
  type = string
  validation {
    condition     = can(regex("^([a-zA-Z])+(([a-zA-Z]|[0-9])*-?)*$", var.cluster_name))
    error_message = "Invalid cluster name."
  }
}

variable "vpc_name" {
  description = "Name of the VPC"
  type = string
  default = "dc-bamboo-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type = string
  default = "10.0.0.0/20"
}

variable "required_tags" {
  description = "List of tags"
  type = map(any)
}