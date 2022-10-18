data "aws_caller_identity" "current" {}

module "nodegroup_launch_template" {
  cluster_name                    = var.cluster_name
  source                          = "./nodegroup_launch_template"
  region                          = var.region
  tags                            = var.tags
  osquery_secret_name             = var.osquery_secret_name
  osquery_secret_region           = local.osquery_secret_region
  osquery_env                     = var.osquery_env
  osquery_version                 = var.osquery_version
  kinesis_log_producers_role_arns = var.kinesis_log_producers_role_arns
}

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
  vpc_id                    = var.vpc_id
  subnets                   = var.subnets
  cluster_service_ipv4_cidr = local.cluster_service_ipv4_cidr

  # These 2 properties below will be deprecated in v18 of the AWS EKS module:
  # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/UPGRADE-18.0.md
  # If upgrading this module to v18 be sure that this deprecation is taken into account.
  kubeconfig_aws_authenticator_command      = "aws"
  kubeconfig_aws_authenticator_command_args = ["eks", "get-token", "--cluster-name", var.cluster_name]

  workers_additional_policies = local.workers_additional_policies

  # Managed Node Groups
  node_groups_defaults = {
    ami_type        = local.ami_type
    disk_size       = var.instance_disk_size
  }

  node_groups = {
    appNodes = {
      name                    = "appNode-${replace(join("-", var.instance_types), ".", "_")}"
      max_capacity            = var.max_cluster_capacity
      desired_capacity        = var.min_cluster_capacity
      min_capacity            = var.min_cluster_capacity
      launch_template_id      = module.nodegroup_launch_template.id
      launch_template_version = module.nodegroup_launch_template.version
      subnets                 = slice(var.subnets, 0, 1)
      instance_types          = var.instance_types
      capacity_type           = "ON_DEMAND"
    }
  }

  map_roles = var.additional_roles
}


resource "aws_autoscaling_group_tag" "this" {
  for_each               = var.tags
  autoscaling_group_name = module.eks.node_groups["appNodes"].resources[0].autoscaling_groups[0].name

  tag {
    key                 = each.key
    value               = each.value
    propagate_at_launch = true
  }
  depends_on = [
    module.eks
  ]
}
