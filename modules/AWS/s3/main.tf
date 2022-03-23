data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }

  force_destroy = true

  acl = "private"

  tags = merge(var.required_tags, tomap({
    "Name" : var.bucket_name
  }))

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # Atlassian required rules and logging
  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 7
    enabled                                = true
    id                                     = "atlassian-policy-incomplete-mpu"
  }
}

resource "aws_s3_bucket_logging" "logging" {
  count = var.logging_bucket == null ? 0 : 1

  bucket = var.bucket_name

  target_bucket = var.logging_bucket
  target_prefix = "${var.bucket_name}/"
}
