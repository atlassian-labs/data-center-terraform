// Policy created following this guide: http://go/osquery-setup
// Microscope has to be manually created at https://microscope.prod.atl-paas.net/services/${var.cluster_name}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "laas" {
  count = var.fleet_enrollment_secret == null ? 0 : 1
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::915926889391:role/pipeline-prod-log-producer-${data.aws_caller_identity.current.account_id}"]
  }
  statement {
    effect    = "Allow"
    actions   = ["ec2:DescribeTags"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "laas" {
  count = var.fleet_enrollment_secret == null ? 0 : 1

  name        = "${local.cluster_name}_LaaS-policy"
  description = "Allows sending logs to LaaS"
  policy      = data.aws_iam_policy_document.laas[0].json
}

data "aws_iam_policy_document" "fleet_enrollment_secret" {
  count = var.fleet_enrollment_secret == null ? 0 : 1

  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.fleet_enrollment_secret[0].arn]
  }
}

resource "aws_iam_policy" "fleet_enrollment_secret" {
  count = var.fleet_enrollment_secret == null ? 0 : 1

  name        = "${local.cluster_name}_Fleet-Enrollment"
  description = "Allows accessing the Fleet Enrollment Secret"
  policy      = data.aws_iam_policy_document.fleet_enrollment_secret[0].json
}

resource "aws_secretsmanager_secret" "fleet_enrollment_secret" {
  count = var.fleet_enrollment_secret == null ? 0 : 1

  name_prefix = "${local.cluster_name}-fleet_enrollment_secret"
}

resource "aws_secretsmanager_secret_version" "fleet_enrollment_secret" {
  count = var.fleet_enrollment_secret == null ? 0 : 1

  secret_id     = aws_secretsmanager_secret.fleet_enrollment_secret[0].id
  secret_string = var.fleet_enrollment_secret
}

