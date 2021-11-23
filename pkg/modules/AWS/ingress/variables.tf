variable "ingress_domain" {
  description = "Domain name for the ingress controller"
  type        = string
}

variable "tags" {
  description = "List of additional tags that will be attached to created resources."
  type        = map(string)
}
