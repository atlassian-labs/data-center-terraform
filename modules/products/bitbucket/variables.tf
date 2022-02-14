#variable "region_name" {
#  description = "Name of the AWS region."
#  type        = string
#}
#
#variable "environment_name" {
#  description = "Name of the environment."
#  type        = string
#  validation {
#    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9\\-]{1,24}$", var.environment_name))
#    error_message = "Invalid environment name. Valid name is up to 25 characters starting with alphabet and followed by alphanumerics. '-' is allowed as well."
#  }
#}

variable "namespace" {
  description = "The namespace where Bitbucket pod will be installed."
  type        = string
}

#variable "vpc" {
#  description = "VPC module that hosts the products."
#  type        = any
#}
#
#variable "eks" {
#  description = "EKS module that hosts the product."
#  type        = any
#}
#
#variable "ingress" {
#  default = null
#  type    = any
#}
#
#variable "db_major_engine_version" {
#  description = "The database major version to use."
#  type        = string
#}
#
#variable "db_allocated_storage" {
#  description = "Allocated storage for database instance in GiB."
#  type        = number
#}
#
#variable "db_instance_class" {
#  description = "Instance class of the RDS instance."
#  type        = string
#}
#
#variable "db_iops" {
#  description = "The requested number of I/O operations per second that the DB instance can support."
#  type        = number
#}
#
variable "bitbucket_configuration" {
  description = "Bitbucket resource spec and chart version"
  type        = map(any)
  validation {
    condition = (length(var.bitbucket_configuration) == 5 &&
      alltrue([
        for o in keys(var.bitbucket_configuration) : contains([
          "helm_version", "cpu", "mem", "min_heap", "max_heap"
        ], o)
    ]))
    error_message = "Bitbucket configuration is not valid."
  }
}

#variable "pvc_claim_name" {
#  description = "Persistent volume claim name for shared home."
#  type        = string
#  validation {
#    condition     = can(regex("^[a-zA-Z]+[a-zA-Z0-9|\\-|_]*$", var.pvc_claim_name))
#    error_message = "Invalid claim name."
#  }
#}
