variable "ingress_domain" {
  description = "Domain name for the ingress controller"
  type        = string
  default     = null
}

variable "enable_https_ingress" {
  description = "If true, Nginx controller will listen on 443 as well."
  type        = bool
}

variable "enable_ssh_tcp" {
  description = "If true, TCP will be enabled at ingress controller level."
  type        = bool
  default     = false
}

variable "load_balancer_access_ranges" {
  description = "List of allowed CIDRs (IPv4 and IPv6) that can access the load balancer."
  type        = list(string)
  validation {
    condition = alltrue([
      for cidr in var.load_balancer_access_ranges : can(regex("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])/([0-9]|1[0-9]|2[0-9]|3[0-2])$", cidr)) || 
      can(regex("^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:))/([0-9]|[1-9][0-9]|1[0-1][0-9]|12[0-8])$", cidr))
    ])
    error_message = "Invalid CIDR. Valid format is a list of IPv4 CIDR '<IPv4>/[0-32]' (e.g: [\"10.0.0.0/18\"]) or IPv6 CIDR '<IPv6>/[0-128]' (e.g: [\"2001:db8::/32\"])."
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
