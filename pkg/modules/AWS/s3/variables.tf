variable "required_tags" {
  type        = map(any)
  description = "List of tags"
}

variable "bucket_name" {
  type        = string
  description = "Name of the bucket to store the terraform state"
  validation {
    condition     = can(regex("^([a-zA-Z])+(([a-zA-Z]|[0-9])*-?)*$", var.bucket_name))
    error_message = "Invalid S3 bucket name."
  }
}
