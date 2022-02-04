# To customise the infrastructure you must provide the value for each of these parameters in config.tfvar

#variable "db_allocated_storage" {
#  description = "Allocated storage for database instance in GiB."
#  default     = 1000
#  type        = number
#}
#
#variable "db_instance_class" {
#  description = "Instance class of the RDS instance."
#  default     = "db.t3.micro"
#  type        = string
#}
#
#variable "db_iops" {
#  description = "The requested number of I/O operations per second that the DB instance can support."
#  default     = 1000
#  type        = number
#}

variable "bitbucket_license" {
  description = "bitbucket license."
  type        = string
  sensitive   = true
}

variable "bitbucket_helm_chart_version" {
  description = "Version of bitbucket Helm chart"
  type        = string
  default     = "1.1.0"
}

variable "bitbucket_cpu" {
  description = "Number of CPUs for bitbucket instance"
  type        = string
  default     = "2"
}

variable "bitbucket_mem" {
  description = "Amount of memory for bitbucket instance"
  type        = string
  default     = "2Gi"
}

variable "bitbucket_min_heap" {
  description = "Minimum heap size for bitbucket instance"
  type        = string
  default     = "512m"
}

variable "bitbucket_max_heap" {
  description = "Maximum heap size for bitbucket instance"
  type        = string
  default     = "1024m"
}

variable "bitbucket_admin_username" {
  description = "bitbucket system administrator username."
  type        = string
}

variable "bitbucket_admin_password" {
  description = "bitbucket system administrator password."
  type        = string
  sensitive   = true
}

variable "bitbucket_admin_display_name" {
  description = "bitbucket system administrator display name."
  type        = string
}

variable "bitbucket_admin_email_address" {
  description = "bitbucket system administrator email address."
  type        = string
}