variable "product" {
  description = "The product that NFS will be created for."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace to install Bitbucket."
  type        = string
}

variable "chart_name_override" {
  description = "Name to override the default chart name for NFS."
  type        = string
  default     = "server"
}
