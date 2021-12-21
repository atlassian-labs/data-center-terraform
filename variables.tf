# To customise the infrastructure you must provide the value for each of these parameters in config.tfvar

variable "region" {
  description = "Name of the AWS region."
  type        = string
  validation {
    condition     = can(regex("(us(-gov)?|ap|ca|cn|eu|sa)-(central|(north|south)?(east|west)?)-[1-9]", var.region))
    error_message = "Invalid region name. Must be a valid AWS region."
  }
}

variable "environment_name" {
  description = "Name for this environment that is going to be deployed. The value will be used to form the name of some resources."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9\\-]{1,24}$", var.environment_name))
    error_message = "Invalid environment name. Valid name is up to 25 characters starting with alphabet and followed by alphanumerics. '-' is allowed as well."
  }
}

variable "resource_tags" {
  description = "Additional tags for all resources to be created."
  type        = map(string)
  default = {
    Terraform = "true"
  }
}

variable "instance_types" {
  description = "Instance types that is preferred for node group."
  type        = list(string)
  default     = ["m5.xlarge"]
}

variable "desired_capacity" {
  description = "Desired number of nodes that the node group should launch with initially."
  type        = number
  validation {
    condition     = var.desired_capacity > 0 && var.desired_capacity <= 10
    error_message = "Desired cluster capacity must be between 1 and 10 (included)."
  }
  default = 1
}

variable "domain" {
  description = "Domain name base for the ingress controller. The final domain is subdomain within this domain. (eg.: environment.domain.com)"
  default     = null
  type        = string
  validation {
    condition     = can(regex("^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", var.domain)) || var.domain == null
    error_message = "Invalid domain name. Valid name is up to 63 characters starting with alphabet and followed by alphanumerics. '-' is allowed as well."
  }
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

variable "bamboo_license" {
  description = "Bamboo license."
  type        = string
  sensitive   = true
}

variable "bamboo_admin_username" {
  description = "Bamboo system administrator username."
  type        = string
}

variable "bamboo_admin_password" {
  description = "Bamboo system administrator password."
  type        = string
  sensitive   = true
}

variable "bamboo_admin_display_name" {
  description = "Bamboo system administrator display name."
  type        = string
}

variable "bamboo_admin_email_address" {
  description = "Bamboo system administrator email address."
  type        = string
}

variable "number_of_bamboo_agents" {
  description = "Number of Bamboo remote agents."
  default     = 50
  type        = number
  validation {
    condition     = var.number_of_bamboo_agents >= 0
    error_message = "Number of agents must be greater or equal 0."
  }
}