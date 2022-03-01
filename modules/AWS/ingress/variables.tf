variable "ingress_domain" {
  description = "Domain name for the ingress controller"
  type        = string
}

variable "enable_tcp" {
  description = "If true, TCP will be enabled at ingress controller level."
  type        = bool
  default     = false
}
