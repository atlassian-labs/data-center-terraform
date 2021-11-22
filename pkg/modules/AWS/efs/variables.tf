variable "efs_name" {
  description = "Name of the EFS."
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9\\-]+$", var.efs_name))
    error_message = "Invalid EFS name."
  }
}

variable "region_name" {
  description = "AWS region."
  type        = string
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
