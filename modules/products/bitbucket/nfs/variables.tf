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
  type        = string
  default     = "10Gi"
}

variable "requests_cpu" {
  description = "The minimum CPU compute to request for the NFS instance"
  type        = string
  default     = "0.25"
}

variable "requests_memory" {
  description = "The minimum amount of memory to allocate to the NFS instance"
  type        = string
  default     = "256Mi"
}

variable "limits_cpu" {
  description = "The maximum CPU compute to allocate to the NFS instance"
  type        = string
  default     = "0.25"
}

variable "limits_memory" {
  description = "The maximum amount of memory to allocate to the NFS instance"
  type        = string
  default     = "256Mi"
}
