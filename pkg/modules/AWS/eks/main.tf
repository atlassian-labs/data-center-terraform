locals {
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

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
      desired_capacity = var.desired_capacity
      max_capacity     = 10
      min_capacity     = 1

      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"
      k8s_labels     = {
        Environment = var.environment_name
        GithubRepo  = "data-center-terraform"
        GithubOrg   = "atlassian-labs"
      }
    }
  }

  tags = var.eks_tags
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  config_path            = "~/.kube/config"
}