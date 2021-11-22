variable "region_name" {
  description = "Name of the AWS region."
  type        = string
}

variable "environment_name" {
  description = "Name of the cluster."
  type        = string
  validation {
    condition     = can(regex("^([a-zA-Z])+(([a-zA-Z]|[0-9])*-?)*$", var.environment_name))
    error_message = "Invalid cluster name."
  }
}

variable "vpc" {
  description = "vpc module that hosts the product."
  type        = any
}

variable "eks" {
  description = "EKS module that hosts the product."
  type        = any
}

variable "efs" {
  description = "EFS module to provide shared-home to the product."
  type        = any
}

variable "share_home_size" {
  description = "Shared home persistent volume size."
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage for database instance in GiB."
  type        = number
}

variable "db_instance_class" {
  description = "Instance class of the RDS instance."
  type        = string
}

variable "db_iops" {
  description = "The requested number of I/O operations per second that the DB instance can support."
  type        = number
}