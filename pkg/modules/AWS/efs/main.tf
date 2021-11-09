# Install the EFS CSI driver for Kubernetes
# See https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html



resource "aws_iam_policy" "efs_csi" {
  name        = "${var.eks.cluster_name}_EFS_CSI"
  description = "EFS CSI policy for cluster ${var.eks.cluster_id}"
  policy      = data.aws_iam_policy_document.efs_csi.json

  tags = var.required_tags
}

# This policy document is modeled after https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/v1.3.0/docs/iam-policy-example.json
data "aws_iam_policy_document" "efs_csi" {
  statement {
    effect = "Allow"

    actions = [
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems"
    ]

    resources = ["*"]
  }
  statement {
    effect = "Allow"

    actions = [
      "elasticfilesystem:CreateAccessPoint"
    ]

    resources = ["*"]
    condition {
      test     = "StringLike"
      values   = ["true"]
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
    }
  }
  statement {
    effect = "Allow"

    actions = [
      "elasticfilesystem:DeleteAccessPoint"
    ]

    resources = ["*"]
    condition {
      test     = "StringLike"
      values   = ["true"]
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
    }
  }
}

module "efs_csi_iam_role" {
  source       = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version      = "3.6.0"
  create_role  = true
  role_name    = "${var.eks.cluster_name}-${local.efs_csi_name}"
  provider_url = replace(var.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns = [
    aws_iam_policy.efs_csi.arn
  ]
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:${local.efs_csi_namespace}:${local.efs_csi_serviceAccount_name}"
  ]
  tags = var.required_tags
}

resource "helm_release" "efs_csi" {
  depends_on = [
    var.eks
  ]

  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"

  name      = local.efs_csi_name
  namespace = local.efs_csi_namespace

  version = local.efs_csi_version

  values = [yamlencode({
    image = {
      repository = local.efs_csi_image_repository
    }
    controller = {
      tags = var.required_tags
      serviceAccount = {
        name = local.efs_csi_serviceAccount_name
        annotations = {
          "eks.amazonaws.com/role-arn" : module.efs_csi_iam_role.this_iam_role_arn
        }
      }
    }
    node = {
      # This setting is required for the nodes to be able to resolve the EFS DNS name. Without this, DNS name resolution
      # will fail and volumes will not mount. See https://github.com/kubernetes-sigs/aws-efs-csi-driver/issues/285#issuecomment-855633486
      dnsPolicy = "None"
      dnsConfig = {
        nameservers = ["169.254.169.253"]
      }
    }
    storageClasses = [
      {
        name         = "efs-sc"
        mountOptions = ["tls"]
        parameters = {
          provisioningMode = "efs-ap"
          fileSystemId     = aws_efs_file_system.efs_csi.id
          directoryPerms   = "700"
          gidRangeStart    = "1000"
          gidRangeEnd      = "2000"
        }
        reclaimPolicy     = "Delete"
        volumeBindingMode = "Immediate"
      }
    ]
  })]
}

# This is to allow access to the EFS filesystem from worker nodes
resource "aws_security_group" "efs_csi" {
  name_prefix = "${var.eks.cluster_name}-efs-csi"
  vpc_id      = var.vpc.vpc_id
  ingress {
    cidr_blocks = var.vpc.private_subnets_cidr_blocks

    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"
  }
  // Terraform removes the default rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.required_tags, { Name : "${var.eks.cluster_name} Allow EFS CSI" })
}


resource "aws_efs_file_system" "efs_csi" {
  creation_token = var.eks.cluster_name

  tags = var.required_tags
}

resource "aws_efs_mount_target" "efs_csi" {
  file_system_id  = aws_efs_file_system.efs_csi.id
  for_each        = toset(var.vpc.private_subnets)
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_csi.id]
}


# This goes to the product level
//resource "kubernetes_persistent_volume_claim" "atlassian-dc-shared-home-pvc" {
//  metadata {
//    # This name is defined in `pom.xml` in the data-center-helm-charts
//    name      = "atlassian-dc-shared-home-pvc"
//    namespace = kubernetes_namespace.ci.metadata[0].name  # TODO - replace with product namespace
//  }
//  spec {
//    access_modes = ["ReadWriteMany"]
//    resources {
//      requests = {
//        storage = "5Gi"
//      }
//    }
//    storage_class_name = "efs-sc"
//  }
//}