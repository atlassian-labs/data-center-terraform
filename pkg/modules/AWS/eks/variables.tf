variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed."
  type        = string
  default     = null
}

variable "subnets" {
  description = "A list of subnets to place the EKS cluster and workers within."
  type        = list(string)
  default     = []
}

variable "environment_name" {
  description = "Name for this environment that is going to be deployed."
  type = string
}


variable "eks_tags" {
  description = "List of additional tags that will be attached to EKS cluster."
  type = map(any)
}