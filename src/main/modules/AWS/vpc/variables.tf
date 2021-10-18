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
}

variable vpc_private_subnet {
  description = "List of private subnets CIDRs"
  type = list
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable vpc_public_subnet {
  description = "List of public subnets CIDRs"
  type = list
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable vpc_azs {
  description = "List of availability zones."
  type = list
  default = []
}