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
  default     = "1"
}

variable "requests_memory" {
  description = "The minimum amount of memory to allocate to the NFS instance"
  type        = string
  default     = "1Gi"
}

variable "limits_cpu" {
  description = "The maximum CPU compute to allocate to the NFS instance"
  type        = string
  default     = "2"
}

variable "limits_memory" {
  description = "The maximum amount of memory to allocate to the NFS instance"
  type        = string
  default     = "2Gi"
}

variable "availability_zone" {
  description = "Availability zone for the EBS volume to be created in."
  type        = string
}

variable "shared_home_snapshot_id" {
  description = "EBS Snapshot ID with content of the product's shared home."
  type        = string
  default     = null
  validation {
    condition     = var.shared_home_snapshot_id == null || can(regex("^snap-\\w{17}$", var.shared_home_snapshot_id))
    error_message = "Provide correct EBS snapshot ID."
  }
}
