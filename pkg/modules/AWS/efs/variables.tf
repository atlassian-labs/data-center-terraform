variable "region_name" {
  description = "AWS region"
  type        = string
}

variable "required_tags" {
  description = "List of required tags"
  type        = map(string)
}

variable "vpc" {
  description = "vpc module that hosts the product"
  type        = any
}

variable "eks" {
  description = "EKS module that hosts the product"
  type        = any
}