module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.24.0"

  # Configure cluster
  cluster_version              = "1.21"
  cluster_name                 = var.cluster_name
  manage_cluster_iam_resources = true

  # Enables IAM roles for service accounts - required for autoscaler
  # https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
  enable_irsa = true

  # Networking
  vpc_id  = var.vpc_id
  subnets = var.subnets

  # These 2 properties below will be deprecated in v18 of the AWS EKS module:
  # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/UPGRADE-18.0.md
  # If upgrading this module to v18 be sure that this deprecation is taken into account.
  kubeconfig_aws_authenticator_command      = "aws"
  kubeconfig_aws_authenticator_command_args = ["eks", "get-token", "--cluster-name", var.cluster_name]

  # Managed Node Groups
  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = var.instance_disk_size
  }

  node_groups = {
    appNodes = {
      name         = "appNode-${replace(join("-", var.instance_types), ".", "_")}"
      max_capacity = var.max_cluster_capacity
      min_capacity = var.min_cluster_capacity

      subnets        = slice(var.subnets, 0, 1)
      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"
    }
  }
}
