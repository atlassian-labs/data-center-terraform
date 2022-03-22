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
}

variable "iops" {
  description = "The requested number of I/O operations per second that the DB instance can support."
  type        = number
}

variable "eks" {
  description = "EKS module that hosts the product."
  type        = any
}

variable "vpc" {
  description = "VPC module that hosts the product."
  type        = any
}

variable "allow_major_version_upgrade" {
  description = "Allow major version upgrade."
  type        = bool
  default     = false
}

variable "major_engine_version" {
  description = "RDS Major engine version for the product."
  default     = "11"
  type        = string
  validation {
    condition     = contains(["10", "11", "12", "13", "14"], var.major_engine_version)
    error_message = "Invalid major engine version. Valid ranges are from 10 to 14 (integer)."
  }
}
