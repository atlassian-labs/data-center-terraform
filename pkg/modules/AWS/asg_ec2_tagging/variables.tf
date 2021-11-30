variable "region" {
  description = "Name of the AWS region."
  type        = string
  validation {
    condition     = can(regex("(us(-gov)?|ap|ca|cn|eu|sa)-(central|(north|south)?(east|west)?)-[1-9]", var.region))
    error_message = "Invalid region name. Must be a valid AWS region."
  }
}

variable "resource_tags" {
  description = "Additional tags for all resources to be created."
  type        = map(string)
  default = {
    Terraform = "true"
  }
}

variable "state_type" {
  description = "Type of the terraform state. Available types: local, s3."
  type        = string
  default     = "s3"
}

variable "s3_bucket" {
  description = "Name of the terraform backend s3 bucket."
  type        = string
  default     = ""
}

variable "bucket_key" {
  description = "Name of the terraform backend s3 bucket key."
  type        = string
  default     = ""
}