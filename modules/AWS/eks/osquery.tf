// Policy created following this guide: http://go/osquery-setup
// Microscope has to be manually created at https://microscope.prod.atl-paas.net/services/${var.cluster_name}

# See: https://hello.atlassian.net/wiki/spaces/OBSERVABILITY/pages/140624694/Logging+pipeline+-+Sending+logs+to+Splunk#Kinesis-Stream-Details
data "aws_iam_policy_document" "laas" {
  count       = var.osquery_secret_name != "" ? 1 : 0
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [var.kinesis_log_producers_role_arns["eu"], var.kinesis_log_producers_role_arns["non-eu"]]
  }
  statement {
    effect    = "Allow"
    actions   = ["ec2:DescribeTags"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "laas" {
  count       = var.osquery_secret_name != "" ? 1 : 0
  name        = "${var.cluster_name}_LaaS-policy"
  description = "Allows sending logs to LaaS"
  policy      = data.aws_iam_policy_document.laas[count.index].json
}

data "aws_iam_policy_document" "fleet_enrollment_secret" {
  count       = var.osquery_secret_name != "" ? 1 : 0
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["arn:aws:secretsmanager:${local.osquery_secret_region}:${local.account_id}:secret:${var.osquery_secret_name}"]
  }
}

resource "aws_iam_policy" "fleet_enrollment_secret" {
  count       = var.osquery_secret_name != "" ? 1 : 0
  name        = "${var.cluster_name}_Fleet-Enrollment"
  description = "Allows accessing the Fleet Enrollment Secret"
  policy      = data.aws_iam_policy_document.fleet_enrollment_secret[count.index].json
}
