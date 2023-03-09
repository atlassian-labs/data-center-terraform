variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9\\-]{1,38}$", var.cluster_name))
    error_message = "Invalid EKS cluster name. Valid name is up to 38 characters starting with an alphabet and followed by the combination of alphanumerics and '-'."
  }
}

variable "region" {
  description = "Region of the EKS cluster."
  type        = string
}

variable "tags" {
  description = "Additional tags for all resources to be created."
  type        = map(string)
}

variable "instance_types" {
  description = "Instance types that is preferred for node group."
  type        = list(string)
}

variable "instance_disk_size" {
  description = "Size of the disk attached to the cluster instance."
  type        = number
}

variable "osquery_secret_name" {
  description = "Fleet enrollment secret name"
  type        = string
}

variable "osquery_secret_region" {
  description = "Fleet enrollment secret AWS region"
  type        = string
}

variable "osquery_env" {
  description = "Osquery environment name"
  type        = string
}

variable "osquery_version" {
  description = "Osquery version"
  type        = string
}

variable "kinesis_log_producers_role_arns" {
  description = "AWS kinesis log producer role"
  type = object({
    eu     = string
    non-eu = string
  })
}
