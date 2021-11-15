variable "vpc_id" {
  description = "VPC where the RDS instance will be deployed."
  type        = string
}

variable "subnets" {
  description = "A list of subnets to place the database within."
  type        = list(string)
}

variable "source_sg" {
  description = "Source security group id that database security group will allow traffic from."
}

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

variable "db_tags" {
  description = "List of additional tags that will be attached to database related resources."
  type        = map(string)
}

variable "eks" {
  description = "EKS module that hosts the product."
  type        = any
}
