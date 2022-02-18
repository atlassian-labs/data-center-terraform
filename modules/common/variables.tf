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

variable "instance_types" {
  description = "Instance types that is preferred for node group."
  type        = list(string)
}

variable "desired_capacity" {
  description = "Desired number of nodes that the node group should launch with initially."
  type        = number
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

variable "share_home_size" {
  description = "Shared home persistent volume size."
  type        = string
}

variable "create_elasticsearch" {
  description = "Provision an AWS Elasticsearch to be used by bitbucket."
  type        = bool
  default     = false
}

variable "elasticsearch_instance_type" {
  description = "Instance type for Bitbucket AWS Elasticsearch."
  type        = string
}

variable "elasticsearch_storage_size" {
  description = "Storage size for Bitbucket elasticsearch instance."
  type        = number
}

variable "elasticsearch_instance_count" {
  description = "Number of nodes for elasticsearch instance"
  type        = number
}