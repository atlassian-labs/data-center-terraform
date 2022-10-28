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
  type = map(string)
}

variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed."
  type        = string
}

variable "subnets" {
  description = "A list of subnets to place the EKS cluster and workers within."
  type        = list(string)
}

variable "instance_types" {
  description = "Instance types that is preferred for node group."
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "Security group ID attached to workers"
  type        = list(string)
}

variable "aws_iam_instance_profile" {
  type = string
  description = "IAM instance profile"
}

variable "instance_disk_size" {
  description = "Size of the disk attached to the cluster instance."
  default     = 50
  type        = number
}

variable "max_cluster_capacity" {
  description = "Maximum number of EC2 instances that cluster can scale up to."
  type        = number

  validation {
    condition     = (var.max_cluster_capacity >= 1 && var.max_cluster_capacity <= 20)
    error_message = "Maximum cluster capacity must be between 1 and 20, inclusive."
  }
}

variable "min_cluster_capacity" {
  description = "Minimum number of EC2 instances for the EKS cluster."
  type        = number
  validation {
    condition     = var.min_cluster_capacity >= 1 && var.min_cluster_capacity <= 20
    error_message = "Minimum cluster capacity must be between 1 and 20, inclusive."
  }
}

variable "k8s_ca" {
  type = string
  description = "K8s cluster ca"
}

variable "api_server_endpoint" {
  type = string
  description = "K8s cluster API endpoint"
}

variable "additional_roles" {
  description = "Additional roles that have access to the cluster."
  type        = list(object({ rolearn = string, username = string, groups = list(string) }))
}

variable "resource_tags" {
  description = "Additional tags for all resources to be created."
  default = {
    Terraform = "true"
  }
  type = map(string)
}

variable "osquery_secret_name" {
  description = "Fleet enrollment secret name"
  type = string
}

variable "osquery_secret_region" {
  description = "Fleet enrollment secret AWS region"
  type = string
}

variable "osquery_env" {
  description = "Osquery environment name"
  type = string
}

variable "osquery_version" {
  description = "Osquery version"
  type = string
}

variable "kinesis_log_producers_role_arns" {
  description = "AWS kinesis log producer role"
  type   = object({
    eu     = string
    non-eu = string
  })
}
