data "aws_iam_policy_document" "s3_confluence_storage" {
  count       = var.confluence_s3_attachments_storage ? 1 : 0
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:ListBucket"]
    resources = [aws_s3_bucket.confluence_storage_bucket[0].arn, format("%s/%s",aws_s3_bucket.confluence_storage_bucket[0].arn,"*")]
  }
}

resource "aws_iam_policy" "s3_confluence_storage" {
  count       = var.confluence_s3_attachments_storage ? 1 : 0
  name        = "${var.cluster_name}-s3-confluence-storage-policy"
  description = "Allows managing S3 bucket"
  policy      = data.aws_iam_policy_document.s3_confluence_storage[count.index].json
}

resource "aws_iam_role" "s3_confluence_storage_role" {
  count = var.confluence_s3_attachments_storage ? 1 : 0
  name  = "${var.cluster_name}-s3-storage-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement: [
      {
        Effect: "Allow",
        Principal: {
          Federated: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oicd_provider}"
        },
        Action: "sts:AssumeRoleWithWebIdentity",
        Condition: {
          StringEquals: {
            "${local.oicd_provider}:aud": "sts.amazonaws.com",
            "${local.oicd_provider}:sub": "system:serviceaccount:${var.namespace}:confluence"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "confluence_s3_storage" {
  count = var.confluence_s3_attachments_storage ? 1 : 0
  policy_arn = aws_iam_policy.s3_confluence_storage[0].arn
  role       = aws_iam_role.s3_confluence_storage_role[0].name
}

resource "aws_iam_role" "node_group" {
  name_prefix = var.cluster_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  for_each   = toset(local.eks_node_policies)
  policy_arn = each.value
  role       = aws_iam_role.node_group.name
}

# iam_role_additional_policies can't have objects which arns need to be computed,
# thus attaching policies to worker node roles outside of eks https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1891
resource "aws_iam_role_policy_attachment" "laas" {
  count      = var.osquery_secret_name != "" ? 1 : 0
  policy_arn = aws_iam_policy.laas[0].arn
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "fleet_enrollment_secret" {
  count      = var.osquery_secret_name != "" ? 1 : 0
  policy_arn = aws_iam_policy.fleet_enrollment_secret[0].arn
  role       = aws_iam_role.node_group.name
}
