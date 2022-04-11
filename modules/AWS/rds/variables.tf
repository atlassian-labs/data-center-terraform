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
  validation {
    condition     = can(regex("^([aA-zZ]|[0-9]|[!#$%^&*(){}?<>,.]).{8,}$", var.db_master_password)) || var.db_master_password == null
    error_message = "Master password must be set. It must be at least 8 characters long and can include any printable ASCII character except /, \", @, or a space."
  }
}