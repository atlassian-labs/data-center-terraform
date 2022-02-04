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

variable "confluence_license" {
  description = "confluence license."
  type        = string
  sensitive   = true
}

variable "confluence_helm_chart_version" {
  description = "Version of confluence Helm chart"
  type        = string
  default     = "1.1.0"
}

variable "confluence_cpu" {
  description = "Number of CPUs for confluence instance"
  type        = string
  default     = "2"
}

variable "confluence_mem" {
  description = "Amount of memory for confluence instance"
  type        = string
  default     = "2Gi"
}

variable "confluence_min_heap" {
  description = "Minimum heap size for confluence instance"
  type        = string
  default     = "512m"
}

variable "confluence_max_heap" {
  description = "Maximum heap size for confluence instance"
  type        = string
  default     = "1024m"
}