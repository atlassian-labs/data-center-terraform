locals {
  log_bucket_name = "atl-default-s3-logging-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
}
