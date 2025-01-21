variable "vpc" {
  description = "VPC module that hosts the product."
  type        = any
}

variable "tags" {
  description = "Additional tags for all resources to be created."
  type        = map(string)
}
