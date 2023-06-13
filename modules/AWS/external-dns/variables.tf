variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9\\-]{1,38}$", var.cluster_name))
    error_message = "Invalid EKS cluster name. Valid name is up to 38 characters starting with an alphabet and followed by the combination of alphanumerics and '-'."
  }
}

variable "zone_id" {
  description = "The zone id of the hosted zone to contain this record."
  type        = string
}

variable "create_external_dns" {
  description = "Should create external dns"
  default     = true
  type        = bool
}

variable "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL of the EKS cluster."
  type        = string
}

variable "ingress_domain" {
  description = "Domain name for the ingress controller."
  type        = string
}
