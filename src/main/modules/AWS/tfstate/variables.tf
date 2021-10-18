variable "required_tags" {
  type = map(any)
  description = "List of tags"
}

variable "bucket_name" {
  type = string
  description = "Name of the bucket to store the terraform state"
}

variable "dynamodb_name" {
  type = string
  description = "Name of the dynamodb table to store the terraform state"
}
