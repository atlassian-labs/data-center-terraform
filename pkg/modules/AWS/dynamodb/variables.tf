variable "required_tags" {
  type = map(any)
  description = "List of tags"
}

variable "dynamodb_name" {
  type = string
  description = "Name of the dynamodb table to store the terraform state"
}
