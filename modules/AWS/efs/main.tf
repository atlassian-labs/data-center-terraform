# Install the EFS CSI driver for Kubernetes
# See https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html



resource "aws_iam_policy" "this" {
  name        = "${var.efs_name}-iam-policy"
  description = "EFS CSI policy for cluster ${var.eks.cluster_id}"
  policy      = data.aws_iam_policy_document.this.json
}

# This policy document is modeled after https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/v1.3.0/docs/iam-policy-example.json
data "aws_iam_policy_document" "this" {
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

module "efs_iam_role" {
  source       = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version      = "3.6.0"
  create_role  = true
  role_name    = "${var.eks.cluster_name}-${local.efs_csi_name}"
  provider_url = replace(var.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns = [
    aws_iam_policy.this.arn
  ]
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:${local.efs_csi_namespace}:${local.efs_csi_serviceAccount_name}"
  ]
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
    replicaCount = var.csi_controller_replica_count
    image = {
      repository = local.efs_csi_image_repository
    }
    controller = {
      serviceAccount = {
        name = local.efs_csi_serviceAccount_name
        annotations = {
          "eks.amazonaws.com/role-arn" : module.efs_iam_role.this_iam_role_arn
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
          fileSystemId     = aws_efs_file_system.this.id
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
resource "aws_security_group" "this" {
  vpc_id = var.vpc.vpc_id
  name   = "${var.efs_name}-security-group"
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
}

resource "aws_efs_file_system" "this" {
  creation_token = var.eks.cluster_name

  tags = { Name : var.efs_name }
}

resource "aws_efs_mount_target" "this" {
  count           = length(var.vpc.private_subnets)
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.vpc.private_subnets[count.index]
  security_groups = [aws_security_group.this.id]
}


# TODO - move to a single PVC for all products - this would mean the products will live in the same namespace (e.g. atlassian)

resource "kubernetes_persistent_volume" "atlassian-dc-share-home-pv" {
  metadata {
    name = "atlassian-dc-share-home-pv"
  }
  spec {
    capacity = {
      storage = local.shared_home_size
    }
    volume_mode        = "Filesystem"
    access_modes       = ["ReadWriteMany"]
    storage_class_name = local.storage_class_name
    mount_options      = ["rw", "lookupcache=pos", "noatime", "intr", "_netdev"]
    persistent_volume_source {
      csi {
        driver        = "efs.csi.aws.com"
        volume_handle = aws_efs_file_system.this.id
      }
    }
  }
}
#
#resource "kubernetes_persistent_volume_claim" "atlassian-dc-share-home-pvc" {
#  metadata {
#    name      = "atlassian-dc-share-home-pvc"
#    namespace = "atlassian"
#  }
#  spec {
#    access_modes = ["ReadWriteMany"]
#    resources {
#      requests = {
#        storage = local.shared_home_size
#      }
#    }
#    volume_name        = kubernetes_persistent_volume.atlassian-dc-share-home-pv.metadata[0].name
#    storage_class_name = local.storage_class_name
#  }
#}
