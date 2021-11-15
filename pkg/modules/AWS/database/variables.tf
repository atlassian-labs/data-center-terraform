variable "product" {
  description = "Name of the product that this database will be created for."
}

variable "rds_instance_id" {
  description = "Name of the DB instance."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9\\-]+[a-z0-9]$", var.rds_instance_id))
    error_message = "Invalid RDS instance name."
  }
}

variable "instance_class" {
  description = "Instance class of the RDS instance."
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage in GiB."
  type        = number

  validation {
    condition     = (var.allocated_storage >= 100 && var.allocated_storage <= 16384)
    error_message = "Invalid allocated storage. Must be between 100 and 16384, inclusive."
  }
}

variable "iops" {
  description = "The requested number of I/O operations per second that the DB instance can support."
  type        = number

  validation {
    condition     = (var.iops >= 1000 && var.iops <= 256000)
    error_message = "Invalid iops. Must be between 1000 and 256000, inclusive."
  }
}
variable "db_tags" {
  description = "List of additional tags that will be attached to database related resources."
  type        = map(string)
}

variable "eks" {
  description = "EKS module that hosts the product."
  type        = any
}

variable "vpc" {
  description = "VPC module that hosts the product."
  type        = any
}
