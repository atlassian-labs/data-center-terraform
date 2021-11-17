# To customise the infrastructure you must provide the value for each of these parameters in config.tfvar

variable "region" {
  description = "Name of the AWS region."
  type        = string
}

variable "environment_name" {
  description = "Name for this environment that is going to be deployed. The value will be used to form the name of some resources."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9\\-]{1,31}$", var.environment_name))
    error_message = "Invalid environment name. Valid name is up to 32 characters starting with alphabet and followed by alphanumerics. '-' is allowed as well."
  }
}

variable "resource_tags" {
  description = "Additional tags for all resources to be created."
  type        = map(string)
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
  description = "Domain name base for the ingress controller. The final domain is subdomain within this domain. (eg.: environment.domain.com)"
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage for database instance in GiB."
  type        = number
  default     = 1000
}

variable "db_instance_class" {
  description = "Instance class of the RDS instance."
  type        = string
  default     = "db.t3.micro"
}

variable "db_iops" {
  description = "The requested number of I/O operations per second that the DB instance can support."
  type        = number
  default     = 1000
}