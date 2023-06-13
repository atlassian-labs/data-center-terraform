variable "region_name" {
  description = "Name of the AWS region"
  type        = string
}

variable "environment_name" {
  description = "Name of the cluster"
  type        = string
  validation {
    condition     = can(regex("^([a-zA-Z])+(([a-zA-Z]|[0-9])*-?)*$", var.environment_name))
    error_message = "Invalid cluster name."
  }
}

variable "eks_version" {
  description = "EKS K8s version"
  type        = number
  validation {
    condition     = can(regex("^1\\.2[1-5]", var.eks_version))
    error_message = "Invalid EKS K8S version. Valid versions are from 1.21 to 1.25."
  }
}

variable "tags" {
  description = "Additional tags for all resources to be created."
  type        = map(string)
}

variable "instance_disk_size" {
  description = "Size of the disk attached to the cluster instance."
  default     = 50
  type        = number
}

variable "instance_types" {
  description = "Instance types that is preferred for node group."
  type        = list(string)
}

variable "min_cluster_capacity" {
  description = "Minimum number of EC2 instances."
  type        = number
}

variable "max_cluster_capacity" {
  description = "Maximum number of EC2 nodes that cluster can scale up to."
  type        = number
}

variable "cluster_downtime_start" {
  description = "Time to scale down the cluster"
  default     = null
  type        = number
}

variable "cluster_downtime_stop" {
  description = "Time to scale up the cluster"
  default     = null
  type        = number
}

variable "cluster_downtime_timezone" {
  description = "Time zone for a cron expression. Valid values are the canonical names of the IANA time zones (such as Etc/GMT+9 or Pacific/Tahiti)."
  default     = "Etc/UTC"
  type        = string
}

variable "domain" {
  description = "Domain name for the ingress controller. The products are running on a subdomain of this domain."
  type        = string
}

variable "namespace" {
  description = "Namespace for Atlassian products."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z]+[a-zA-Z0-9|\\-]*[a-zA-Z]+$", var.namespace)) // RFC 1123 DNS labels
    error_message = "Invalid namespace. Namespace should only have alphanumeric characters and '-' and start and end with a letter."
  }
}

variable "enable_ssh_tcp" {
  description = "If true, TCP will be enabled at ingress controller level."
  type        = bool
  default     = false
}

variable "eks_additional_roles" {
  description = "Additional roles that have access to the cluster."
  type        = list(object({ rolearn = string, username = string, groups = list(string) }))
}

variable "whitelist_cidr" {
  description = "List of CIDRs allowed that have access to the application(s)."
  type        = list(string)
}

variable "enable_https_ingress" {
  description = "If true, Nginx controller will listen on 443 as well."
  type        = bool
}

variable "create_external_dns" {
  description = "Should create external dns"
  default     = false
  type        = bool
}

variable "additional_namespaces" {
  description = "List of additional namespaces to create."
  type        = list(string)
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

variable "osquery_fleet_enrollment_host" {
  type = string
}

variable "kinesis_log_producers_role_arns" {
  description = "AWS kinesis log producer role"
  type = object({
    eu     = string
    non-eu = string
  })
}

variable "monitoring_enabled" {
  type    = bool
  default = false
}

variable "monitoring_grafana_expose_lb" {
  type    = bool
  default = false
}

variable "prometheus_pvc_disk_size" {
  description = "Size of prometheus PVC."
  default     = "10Gi"
  type        = string
}

variable "grafana_pvc_disk_size" {
  description = "Size of Grafana PVC."
  default     = "10Gi"
  type        = string
}

variable "monitoring_custom_values_file" {
  description = "Path to monitoring stack custom values file"
  type        = string
  default     = ""
}
