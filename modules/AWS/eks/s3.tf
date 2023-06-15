resource "aws_s3_bucket" "confluence_storage_bucket" {
  count         = var.confluence_s3_attachments_storage ? 1 : 0
  bucket        = "${var.cluster_name}-confluence-storage"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "confluence_s3" {
  count  = var.confluence_s3_attachments_storage ? 1 : 0
  bucket = aws_s3_bucket.confluence_storage_bucket[count.index].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "confluence_storage_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.confluence_s3]
  count      = var.confluence_s3_attachments_storage ? 1 : 0
  bucket     = aws_s3_bucket.confluence_storage_bucket[count.index].id
  acl        = "private"
}
