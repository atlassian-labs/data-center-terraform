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

      tags = var.eks_tags
    }
  }

  tags = var.eks_tags
}

