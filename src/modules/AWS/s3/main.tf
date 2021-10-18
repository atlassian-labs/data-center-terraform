data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }

  acl = "private"

  tags = merge(var.required_tags, tomap({
    "Name" : "terraform_state"
  }))

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  lifecycle {
    prevent_destroy = false
  }

  # Atlassian required rules and logging
  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 7
    enabled                                = true
    id                                     = "atlassian-policy-incomplete-mpu"
  }
  logging {
    target_bucket = "atl-default-s3-logging-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
    target_prefix = "${var.bucket_name}/"
  }
}
