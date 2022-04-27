variable "region_name" {
  description = "Name of the AWS region"
  type        = string
}

variable "environment_name" {
  description = "Name of the cluster"
  type        = string
  validation {
    condition     = can(regex("^([a-zA-Z])+(([a-zA-Z]|[0-9])*-?)*$", var.environment_name))
    error_message = "Invalid cluster name."
  }
}

variable "instance_disk_size" {
  description = "Size of the disk attached to the cluster instance."
  default     = 50
  type        = number
}

variable "instance_types" {
  description = "Instance types that is preferred for node group."
  type        = list(string)
}

variable "min_cluster_capacity" {
  description = "Minimum number of EC2 instances."
  type        = number
}

variable "max_cluster_capacity" {
  description = "Maximum number of EC2 nodes that cluster can scale up to."
  type        = number
}

variable "domain" {
  description = "Domain name for the ingress controller. The products are running on a subdomain of this domain."
  type        = string
}

variable "namespace" {
  description = "Namespace for Atlassian products."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z]+[a-zA-Z0-9|\\-]*[a-zA-Z]+$", var.namespace)) // RFC 1123 DNS labels
    error_message = "Invalid namespace. Namespace should only have alphanumeric characters and '-' and start and end with a letter."
  }
}

variable "shared_home_size" {
  description = "Shared home persistent volume size."
  type        = string
  validation {
    condition     = can(regex("^[0-9]+([gG]|Gi)$", var.shared_home_size)) || var.shared_home_size == null
    error_message = "Invalid shared home persistent volume size. Should be a number followed by 'Gi' or 'g'."
  }
}

variable "enable_ssh_tcp" {
  description = "If true, TCP will be enabled at ingress controller level."
  type        = bool
  default     = false
}