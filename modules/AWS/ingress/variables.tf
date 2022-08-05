variable "ingress_domain" {
  description = "Domain name for the ingress controller"
  type        = string
  default     = null
}

variable "enable_ssh_tcp" {
  description = "If true, TCP will be enabled at ingress controller level."
  type        = bool
  default     = false
}

variable "loadBalancerSourceRanges" {
  description = "List of allowed CIDRs that can access the load balancer."
  type        = list(string)
  validation {
    condition = alltrue([
    for cidr in var.loadBalancerSourceRanges : can(regex("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])/([0-9]|1[0-9]|2[0-9]|3[0-2])$", cidr))])
    error_message = "Invalid CIDR. Valid format is a list of '<IPv4>/[0-32]' e.g: [\"10.0.0.0/18\"]."
  }
}
