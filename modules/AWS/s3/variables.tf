variable "required_tags" {
  type        = map(string)
  description = "List of tags"
}

variable "bucket_name" {
  type        = string
  description = "Name of the bucket to store the terraform state"
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", var.bucket_name))
    error_message = "Invalid S3 bucket name. Valid name is up to 63 characters starting with lower-case only alphabet and followed by lower-case alphanumerics. '-' and '.' are allowed as well."
  }
}

variable "logging_bucket" {
  type        = string
  description = "Name of the bucket to store the logs"
  validation {
    condition     = var.logging_bucket == null || can(regex("^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", var.logging_bucket))
    error_message = "Invalid logging bucket name. Valid name is up to 63 characters starting with lower-case only alphabet and  followed by lower-case alphanumerics. '-' and '.' are allowed as well."
  }
}