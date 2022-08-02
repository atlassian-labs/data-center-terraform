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
  description = "List of allowed CIDRs allow to access to the loadbalancer."
  type        = list(string)
  validation {
    condition = alltrue([
    for cidr in var.loadBalancerSourceRanges : can(regex("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])/([1-9]|1[0-9]|2[0-4])$", cidr))])
    error_message = "Invalid whitelist CIDR. Valid format is a list of '<IPv4>/[1-24]' e.g: [\"10.0.0.0/18\"]."
  }
}
