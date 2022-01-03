variable "region_name" {
  description = "Name of the AWS region."
  type        = string
}

variable "environment_name" {
  description = "Name of the environment."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9\\-]{1,24}$", var.environment_name))
    error_message = "Invalid environment name. Valid name is up to 25 characters starting with alphabet and followed by alphanumerics. '-' is allowed as well."
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

variable "ingress" {
  default = null
  type    = any
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

variable "license" {
  description = "Bamboo license."
  type        = string
  sensitive   = true
}

variable "admin_username" {
  description = "System administrator username."
  type        = string
}

variable "admin_password" {
  description = "System administrator password."
  type        = string
  sensitive   = true
}

variable "admin_display_name" {
  description = "System administrator display name."
  type        = string
}

variable "admin_email_address" {
  description = "System administrator email address."
  type        = string
}