module "autoscaler_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.13.2"

  create_role  = true
  role_name    = "${var.cluster_name}-autoscaler"
  provider_url = replace(module.eks.cluster_oidc_issuer_url, "https://", "")

  role_policy_arns = [
    aws_iam_policy.cluster_autoscaler.arn
  ]
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:${local.autoscaler_service_account_namespace}:${local.autoscaler_service_account_name}"
  ]
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name_prefix = "cluster-autoscaler"
  description = "EKS cluster-autoscaler policy for cluster ${module.eks.cluster_id}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid    = "clusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeInstanceTypes"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "clusterAutoscalerOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${module.eks.cluster_id}"
      values = [
        "owned"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values = [
        "true"
      ]
    }
  }
}

resource "helm_release" "cluster-autoscaler" {
  depends_on = [
    module.eks
  ]

  name       = "cluster-autoscaler"
  namespace  = local.autoscaler_service_account_namespace
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = local.autoscaler_version

  values = [yamlencode({
    awsRegion = var.region
    rbac = {
      create = true
      serviceAccount = {
        name = local.autoscaler_service_account_name
        annotations = {
          "eks.amazonaws.com/role-arn" : module.autoscaler_iam_role.iam_role_arn
        }
      }
    }
    autoDiscovery = {
      enabled     = true
      clusterName = var.cluster_name
    }
  })]
}

