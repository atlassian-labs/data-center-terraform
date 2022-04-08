variable "product" {
  description = "Name of the product that this database will be created for."
}

variable "rds_instance_id" {
  description = "The DB instance identifier. This is the unique value for the DB instance."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9\\-]+[a-z0-9]$", var.rds_instance_id))
    error_message = "Invalid RDS instance name."
  }
}

variable "rds_instance_name" {
  description = "Name of the RDS instance. This will be used as the name of the DB instance."
  type        = string
  default     = null
}

variable "product_db_name" {
  description = "Name of the product database."
  type        = string
  default     = null
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

variable "major_engine_version" {
  description = "RDS Major engine version for the product."
  default     = "11"
  type        = string
  validation {
    condition     = contains(["10", "11", "12", "13"], var.major_engine_version)
    error_message = "Invalid major engine version. Valid ranges are from 10 to 13 (integer)."
  }
}

variable "snapshot_identifier" {
  description = "Snapshot identifier for RDS. If specified, the DB instance will be created from the snapshot."
  type        = string
  default     = null
}

variable "db_master_username" {
  description = "Master username for the RDS instance."
  type        = string
  default     = null
}

variable "db_master_password" {
  description = "Master password for the RDS instance."
  type        = string
  default     = null
}