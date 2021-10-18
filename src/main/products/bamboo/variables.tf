variable "region_name" {
  description = "Name of the AWS region"
  type = string
}

variable "cluster_name" {
  description = "Name of the associated cluster"
  type = string
}

variable "required_tags" {
  description = "List of tags"
  type = map(any)
}

variable "vpc_name" {
  description = "Name of the VPC"
  type = string
  default = "dc-bamboo-vpc"
}
