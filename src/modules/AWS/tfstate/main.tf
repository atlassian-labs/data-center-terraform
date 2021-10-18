// This dynamodb table is used to lock the terraform state preventing more than a single process from modifying resources
// in the account at the same time.

resource "aws_dynamodb_table" "terraform_statelock" {
  provider       = aws
  name           = var.dynamodb_name
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  tags = merge(var.required_tags, tomap({
    "Name" : "terraform_statelock"
  }))

  attribute {
    name = "LockID"
    type = "S"
  }
  lifecycle {
    prevent_destroy = false
  }
}
