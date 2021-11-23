module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.23.0"

  # Configure cluster
  cluster_version              = "1.21"
  cluster_name                 = var.cluster_name
  manage_cluster_iam_resources = true

  # Networking
  vpc_id  = var.vpc_id
  subnets = var.subnets

  # Managed Node Groups
  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  node_groups = {
    appNodes = {
      name             = "appNode"
      desired_capacity = var.desired_capacity
      max_capacity     = 10
      min_capacity     = 1

      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"

      tags = local.eks_tags
    }
  }

  tags = local.eks_tags
}

data "aws_default_tags" "current" {}

resource "aws_autoscaling_group_tag" "tag" {
  for_each               = data.aws_default_tags.current.tags
  autoscaling_group_name = module.eks.node_groups.appNodes.resources[0].autoscaling_groups[0].name

  tag {
    key                 = each.key
    value               = each.value
    propagate_at_launch = true
  }
}