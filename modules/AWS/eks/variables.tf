variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9\\-]{1,38}$", var.cluster_name))
    error_message = "Invalid EKS cluster name. Valid name is up to 38 characters starting with an alphabet and followed by the combination of alphanumerics and '-'."
  }
}

variable "region" {
  description = "Region of the EKS cluster."
  type        = string
}

variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed."
  type        = string
}

variable "subnets" {
  description = "A list of subnets to place the EKS cluster and workers within."
  type        = list(string)
}

variable "instance_types" {
  description = "Instance types that is preferred for node group."
  type        = list(string)
}

variable "instance_disk_size" {
  description = "Size of the disk attached to the cluster instance."
  default     = 50
  type        = number
}

variable "max_cluster_capacity" {
  description = "Maximum number of EC2 instances that cluster can scale up to."
  type        = number

  validation {
    condition     = (var.max_cluster_capacity >= 1 && var.max_cluster_capacity <= 20)
    error_message = "Maximum cluster capacity must be between 1 and 20, inclusive."
  }
}

variable "min_cluster_capacity" {
  description = "Minimum number of EC2 instances for the EKS cluster."
  type        = number
  validation {
    condition     = var.min_cluster_capacity >= 1 && var.min_cluster_capacity <= 20
    error_message = "Minimum cluster capacity must be between 1 and 20, inclusive."
  }
}