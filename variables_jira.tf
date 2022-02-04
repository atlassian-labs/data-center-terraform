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

variable "jira_license" {
  description = "jira license."
  type        = string
  sensitive   = true
}

variable "jira_helm_chart_version" {
  description = "Version of jira Helm chart"
  type        = string
  default     = "1.1.0"
}

variable "jira_cpu" {
  description = "Number of CPUs for jira instance"
  type        = string
  default     = "2"
}

variable "jira_mem" {
  description = "Amount of memory for jira instance"
  type        = string
  default     = "2Gi"
}

variable "jira_min_heap" {
  description = "Minimum heap size for jira instance"
  type        = string
  default     = "512m"
}

variable "jira_max_heap" {
  description = "Maximum heap size for jira instance"
  type        = string
  default     = "1024m"
}