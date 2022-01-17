variable "state_type" {
  description = "Type of the terraform state. Available types: local, s3."
  type        = string
  default     = "s3"
}
