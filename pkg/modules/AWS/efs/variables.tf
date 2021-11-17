variable "region_name" {
  description = "AWS region."
  type        = string
}

variable "efs_tags" {
  description = "List of additional tags that will be attached to EFS resources."
  type        = map(string)
}

variable "vpc" {
  description = "VPC module that hosts the product."
  type        = any
}

variable "eks" {
  description = "EKS module that hosts the product."
  type        = any
}

variable "csi_controller_replica_count" {
  description = "Number of desired EFS CSI controllers."
  type        = number
}
