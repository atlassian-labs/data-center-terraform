variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9\\-]+$", var.cluster_name))
    error_message = "Invalid EKS cluster name."
  }
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

variable "desired_capacity" {
  description = "Desired number of nodes that the node group should launch with initially."
  type        = number

  validation {
    condition     = (var.desired_capacity >= 1 && var.desired_capacity <= 10)
    error_message = "Desired capacity must be between 1 and 10, inclusive."
  }
}

variable "ingress_domain" {
  description = "Domain name for the ingress controller"
  type        = string
}