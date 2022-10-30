data "aws_caller_identity" "current" {}

# iam_role_additional_policies can't have objects which arns need to be computed,
# thus attaching policies to worker node roles outside of eks
resource "aws_iam_role_policy_attachment" "laas" {
  count      = var.osquery_secret_name != "" ? 1 : 0
  policy_arn = aws_iam_policy.laas[0].arn
  role       = "${var.cluster_name}-nodegroup-role"
}

resource "aws_iam_role_policy_attachment" "fleet_enrollment_secret" {
  count      = var.osquery_secret_name != "" ? 1 : 0
  policy_arn = aws_iam_policy.fleet_enrollment_secret[0].arn
  role       = "${var.cluster_name}-nodegroup-role"
}

module "nodegroup_launch_template" {
  cluster_name                    = var.cluster_name
  source                          = "./nodegroup_launch_template"
  region                          = var.region
  tags                            = var.tags
  instance_types                  = var.instance_types
  osquery_secret_name             = var.osquery_secret_name
  osquery_secret_region           = local.osquery_secret_region
  osquery_env                     = var.osquery_env
  osquery_version                 = var.osquery_version
  kinesis_log_producers_role_arns = var.kinesis_log_producers_role_arns
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.30.2"

  # Configure cluster
  cluster_version = "1.21"
  cluster_name    = var.cluster_name
  create_iam_role = true
  create_cloudwatch_log_group = false

  # add-ons need to be explicitly declared: kube-proxy and vpc-cni are must-have ones
  cluster_addons = {
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }

  }

  # We're creating eks managed nodegroup, hence aws-auth it handled by EKS
  manage_aws_auth_configmap = true
  aws_auth_roles            = var.additional_roles

  # Enables IAM roles for service accounts - required for autoscaler and potentially Atlassian apps
  # https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
  enable_irsa = true

  # Networking
  vpc_id                    = var.vpc_id
  subnet_ids                = var.subnets
  cluster_service_ipv4_cidr = local.cluster_service_ipv4_cidr

  # Managed node group defaults
  eks_managed_node_group_defaults = {
    ami_type  = local.ami_type
    disk_size = var.instance_disk_size
  }

  # Self-managed node group. We explicitly disable automatic launch template creation
  # to use a custom launch template with user data and resource_tags
  eks_managed_node_groups = {
    appNodes = {
      name                         = "appNode-${replace(join("-", var.instance_types), ".", "_")}"
      max_size                     = var.max_cluster_capacity
      desired_size                 = var.min_cluster_capacity
      min_size                     = var.min_cluster_capacity
      subnet_ids                   = slice(var.subnets, 0, 1)
      capacity_type                = "ON_DEMAND"
      create_launch_template       = false
      launch_template_name         = "${var.cluster_name}-launch-template"
      launch_template_version      = module.nodegroup_launch_template.version
      iam_role_name                = "${var.cluster_name}-nodegroup-role"
      iam_role_additional_policies = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
    }
  }
}

resource "aws_autoscaling_group_tag" "this" {
  for_each               = var.tags
  autoscaling_group_name = module.eks.eks_managed_node_groups.appNodes.node_group_resources[0].autoscaling_groups[0].name
  tag {
    key                 = each.key
    value               = each.value
    propagate_at_launch = true
  }
  depends_on = [
    module.eks
  ]
}
