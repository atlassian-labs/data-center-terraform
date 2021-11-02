variable "required_tags" {
  type        = map(any)
  description = "List of tags"
}

variable "dynamodb_name" {
  type        = string
  description = "Name of the dynamodb table to store the terraform state"
  validation {
    condition     = can(regex("^([a-zA-Z])+(([a-zA-Z]|[0-9])*_?)*$", var.dynamodb_name))
    error_message = "Invalid DynamoDB table name."
  }
}
