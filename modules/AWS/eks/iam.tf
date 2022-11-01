resource "aws_iam_role" "node_group" {
  name = var.cluster_name

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
  for_each = toset(local.eks_node_policies)
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
