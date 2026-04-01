variable "ingress_domain" {
  description = "Domain name for the Gateway API"
  type        = string
  default     = null
}

variable "namespace" {
  description = "Namespace for Atlassian products where the Gateway resource will be created"
  type        = string
}

variable "load_balancer_access_ranges" {
  description = "List of allowed CIDRs that can access the load balancer."
  type        = list(string)
  validation {
    condition = alltrue([
    for cidr in var.load_balancer_access_ranges : can(regex("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])/([0-9]|1[0-9]|2[0-9]|3[0-2])$", cidr))])
    error_message = "Invalid CIDR. Valid format is a list of '<IPv4>/[0-32]' e.g: [\"10.0.0.0/18\"]."
  }
}

variable "vpc" {
  description = "VPC module that hosts the products."
  type        = any
}

variable "additional_namespaces" {
  description = "List of additional namespaces to create."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags for all resources to be created."
  type        = map(string)
}

variable "cluster_name" {
  description = "EKS cluster name, used to generate kubeconfig for kubectl provisioners."
  type        = string
}

variable "region" {
  description = "AWS region of the EKS cluster."
  type        = string
}

variable "enable_ssh_tcp" {
  description = "Expose TCP listener on port 7999 and create TCPRoute for Bitbucket SSH connectivity."
  type        = bool
  default     = false
}
