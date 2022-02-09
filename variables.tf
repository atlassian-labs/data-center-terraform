# To customise the infrastructure you must provide the value for each of these parameters in config.tfvar

################################################################################
# Common Settings
################################################################################

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
    condition     = can(regex("^[a-z][a-z0-9\\-]{1,24}$", var.environment_name))
    error_message = "Invalid environment name. Valid name is up to 24 characters starting with lower case alphabet and followed by alphanumerics. '-' is allowed as well."
  }
}

variable "products" {
  description = "List of the products to be installed."
  type        = list(string)
  validation {
    condition     = alltrue([for o in var.products : contains(["jira", "bitbucket", "confluence", "bamboo"], lower(o))])
    error_message = "Non-supported product is provided. Only 'jira', 'bitbucket', 'confluence',  and 'bamboo' are supported."
  }
}

variable "resource_tags" {
  description = "Additional tags for all resources to be created."
  default = {
    Terraform = "true"
  }
  type = map(string)
}

variable "instance_types" {
  description = "Instance types that is preferred for node group."
  default     = ["m5.xlarge"]
  type        = list(string)
}

variable "desired_capacity" {
  description = "Desired number of nodes that the node group should launch with initially."
  default     = 1
  type        = number
  validation {
    condition     = var.desired_capacity > 0 && var.desired_capacity <= 10
    error_message = "Desired cluster capacity must be between 1 and 10 (included)."
  }
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


variable "local_helm_charts_path" {
  description = "Path to a local directory with Helm charts to install"
  type        = string
  validation {
    condition     = can(regex("^[.?\\/?[a-zA-Z0-9|\\-|_]*]*$", var.local_helm_charts_path))
    error_message = "Invalid local Helm chart path."
  }
  default = ""
}

################################################################################
# Bamboo Settings
################################################################################

variable "bamboo_db_allocated_storage" {
  description = "Allocated storage for database instance in GiB."
  default     = 1000
  type        = number
}

variable "bamboo_db_instance_class" {
  description = "Instance class of the RDS instance."
  default     = "db.t3.micro"
  type        = string
}

variable "bamboo_db_iops" {
  description = "The requested number of I/O operations per second that the DB instance can support."
  default     = 1000
  type        = number
}

variable "bamboo_dataset_url" {
  description = "URL of the dataset to restore in the Bamboo instance"
  type        = string
  default     = null
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

variable "bamboo_helm_chart_version" {
  description = "Version of Bamboo Helm chart"
  type        = string
  default     = "1.0.0"
}

variable "bamboo_agent_helm_chart_version" {
  description = "Version of Bamboo agent Helm chart"
  type        = string
  default     = "1.0.0"
}

variable "bamboo_cpu" {
  description = "Number of CPUs for Bamboo instance"
  type        = string
  default     = "1"
}

variable "bamboo_mem" {
  description = "Amount of memory for Bamboo instance"
  type        = string
  default     = "1Gi"
}

variable "bamboo_min_heap" {
  description = "Minimum heap size for Bamboo instance"
  type        = string
  default     = "256m"
}

variable "bamboo_max_heap" {
  description = "Maximum heap size for Bamboo instance"
  type        = string
  default     = "512m"
}

variable "bamboo_agent_cpu" {
  description = "Number of CPUs for Bamboo agent instance"
  type        = string
  default     = "0.25"
}

variable "bamboo_agent_mem" {
  description = "Amount of memory for Bamboo agent instance"
  type        = string
  default     = "256m"
}

variable "number_of_bamboo_agents" {
  description = "Number of Bamboo remote agents."
  default     = 5
  type        = number
  validation {
    condition     = var.number_of_bamboo_agents >= 0
    error_message = "Number of agents must be greater than or equal to 0."
  }
}

variable "bamboo_install_local_chart" {
  description = "If true installs Bamboo and Agents using local Helm charts located in local_helm_charts_path"
  type        = bool
  default     = false
}
