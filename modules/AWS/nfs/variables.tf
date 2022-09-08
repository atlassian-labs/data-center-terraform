variable "namespace" {
  description = "Kubernetes namespace to install NFS server."
  type        = string
}

variable "product" {
  description = "Product name to install NFS server for."
  type        = string
}

variable "chart_name" {
  description = "The chart name to use."
  type        = string
  default     = "server"
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

variable "shared_home_size" {
  description = "The storage capacity to allocate to shared home"
  type        = string
  validation {
    condition     = can(regex("^[0-9]+([gG]|Gi)$", var.shared_home_size))
    error_message = "Invalid shared home persistent volume size. Should be a number followed by 'Gi' or 'g'."
  }
}

variable "cluster_service_ipv4" {
  description = "The static IP address for NFS service."
  type        = string
  validation {
    condition     = can(regex("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$", var.cluster_service_ipv4))
    error_message = "Invalid IPv4 Address."
  }
}