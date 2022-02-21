variable "namespace" {
  description = "Kubernetes namespace to install NFS server."
  type        = string
}

variable "chart_name" {
  description = "The chart name to use."
  type        = string
  default     = "server"
}

variable "capacity" {
  description = "The storage capacity to allocate to the NFS"
  type = string
  default = "10Gi"
}

