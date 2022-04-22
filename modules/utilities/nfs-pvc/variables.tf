variable "namespace" {
  description = "Kubernetes namespace to install NFS server."
  type        = string
}

variable "product" {
  description = "Product name to install NFS server for."
  type        = string
}

variable "shared_home_size" {
  description = "The storage capacity to allocate to local home"
  type        = string
  default     = "5Gi"
}

variable "nfs_server_ip" {
  description = "The IP address of the NFS server."
  type        = string
}