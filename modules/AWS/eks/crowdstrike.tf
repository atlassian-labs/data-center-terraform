data "aws_iam_policy_document" "crowdstrike_s3" {
  count = var.crowdstrike_secret_name != "" ? 1 : 0
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::trust-shared-agents/*"]
  }
}

resource "aws_iam_policy" "crowdstrike_s3" {
  count       = var.crowdstrike_secret_name != "" ? 1 : 0
  name        = "${var.cluster_name}_crowdstrike_s3"
  description = "Allows accessing Crowdstrike S3 bucket to download rpm"
  policy      = data.aws_iam_policy_document.crowdstrike_s3[count.index].json
}

data "aws_iam_policy_document" "crowdstrike_secret" {
  count = var.crowdstrike_secret_name != "" ? 1 : 0
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["arn:aws:secretsmanager:*:${var.crowdstrike_aws_account_id}:secret:shared/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["arn:aws:kms:*:${var.crowdstrike_aws_account_id}:key/${var.crowdstrike_kms_key_name}"]
  }
}

resource "aws_iam_policy" "crowdstrike_secret" {
  count       = var.crowdstrike_secret_name != "" ? 1 : 0
  name        = "${var.cluster_name}_crowdstrike_secret"
  description = "Allows accessing Crowdstrike S3 bucket to download rpm"
  policy      = data.aws_iam_policy_document.crowdstrike_secret[count.index].json
}