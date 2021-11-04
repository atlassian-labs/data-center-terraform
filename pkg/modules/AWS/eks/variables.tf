variable "cluster_name" {
  description = "Name of the EKS cluster."
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

variable "environment_name" {
  description = "Name for this environment that is going to be deployed."
  type = string
}

variable "eks_tags" {
  description = "List of additional tags that will be attached to EKS cluster."
  type = map(string)
}

variable "instance_types" {
  description = "Instance types that is preferred for node group."
  type = list(string)
}

variable "desired_capacity" {
  description = "Desired number of nodes that the node group should launch with initially."
  type = number
  default = 2
}