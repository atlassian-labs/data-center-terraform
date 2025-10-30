data "aws_caller_identity" "current" {}

data "aws_launch_template" "nodes" {
  id = module.nodegroup_launch_template.id
}

module "nodegroup_launch_template" {
  cluster_name                    = var.cluster_name
  source                          = "./nodegroup_launch_template"
  region                          = var.region
  tags                            = var.tags
  instance_types                  = var.instance_types
  instance_disk_size              = var.instance_disk_size
  osquery_secret_name             = var.osquery_secret_name
  osquery_secret_region           = local.osquery_secret_region
  osquery_env                     = var.osquery_env
  osquery_version                 = var.osquery_version
  kinesis_log_producers_role_arns = var.kinesis_log_producers_role_arns
  osquery_fleet_enrollment_host   = var.osquery_fleet_enrollment_host
  crowdstrike_secret_name         = var.crowdstrike_secret_name
  crowdstrike_aws_account_id      = var.crowdstrike_aws_account_id
  falcon_sensor_version           = var.falcon_sensor_version
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  # Configure cluster
  cluster_version             = var.eks_version
  cluster_name                = var.cluster_name
  create_iam_role             = true
  create_cloudwatch_log_group = false

  # add-ons need to be explicitly declared: kube-proxy and vpc-cni are must-have ones
  cluster_addons = {
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts_on_create = "OVERWRITE"
      configuration_values = jsonencode({
        env = {
          # Enable IPv6 for pods
          ENABLE_IPV6 = "true"
          # Enable prefix delegation
          ENABLE_PREFIX_DELEGATION = "true"
        }
      })
    }
    aws-ebs-csi-driver = {
      resolve_conflicts_on_create = "OVERWRITE"
      configuration_values = jsonencode({
        defaultStorageClass = {
          enabled = true
        }
      })
    }
  }

  # We're creating eks managed nodegroup, hence aws-auth is handled by EKS
  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API_AND_CONFIG_MAP"
  access_entries                           = local.iam_access_entries

  cluster_endpoint_public_access = true

  # Enables IAM roles for service accounts - required for autoscaler and potentially Atlassian apps
  # https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
  enable_irsa              = true
  iam_role_use_name_prefix = false

  # we won't use kms key to encrypt secrets in etcd
  # and may want to revisit this in future
  # to and make it configurable (requires kms permissions)
  create_kms_key            = false
  cluster_encryption_config = {}

  # Networking
  vpc_id                    = var.vpc_id
  subnet_ids                = var.subnets
  cluster_service_ipv4_cidr = local.cluster_service_ipv4_cidr
  
  # Enable IPv6 for cluster
  cluster_ip_family         = "ipv6"
  create_cni_ipv6_iam_policy = true

  # Managed node group defaults
  eks_managed_node_group_defaults = {
    ami_type = local.ami_type
  }

  # Self-managed node group. We explicitly disable automatic launch template creation
  # to use a custom launch template with user data and resource_tags
  eks_managed_node_groups = {
    appNodes = {
      name                     = "appNode-${replace(join("-", var.instance_types), ".", "_")}"
      max_size                 = var.max_cluster_capacity
      desired_size             = var.min_cluster_capacity
      min_size                 = var.min_cluster_capacity
      subnet_ids               = slice(var.subnets, 0, 1)
      capacity_type            = "ON_DEMAND"
      create_launch_template   = false
      launch_template_id       = data.aws_launch_template.nodes.id
      launch_template_version  = module.nodegroup_launch_template.version
      create_iam_role          = false
      iam_role_arn             = aws_iam_role.node_group.arn
      iam_role_use_name_prefix = false
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

# we need to tag this security group because it's not created by Terraform
resource "aws_ec2_tag" "cluster_primary_security_group" {
  for_each    = { for k, v in var.tags : k => v if k != "Name" }
  key         = each.key
  value       = each.value
  resource_id = module.eks.cluster_primary_security_group_id
}

resource "aws_autoscaling_schedule" "downtime" {
  count                  = local.use_downtime ? 1 : 0
  scheduled_action_name  = "downtime"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  autoscaling_group_name = module.eks.eks_managed_node_groups.appNodes.node_group_resources[0].autoscaling_groups[0].name
  recurrence             = "0 ${var.cluster_downtime_start} * * *"
  time_zone              = var.cluster_downtime_timezone
  lifecycle {
    ignore_changes = [start_time]
  }
}

resource "aws_autoscaling_schedule" "business_hours" {
  count                  = local.use_downtime ? 1 : 0
  scheduled_action_name  = "business-hours"
  min_size               = var.min_cluster_capacity
  max_size               = var.max_cluster_capacity
  desired_capacity       = var.min_cluster_capacity
  autoscaling_group_name = module.eks.eks_managed_node_groups.appNodes.node_group_resources[0].autoscaling_groups[0].name
  recurrence             = "0 ${var.cluster_downtime_stop} * * MON-FRI"
  time_zone              = var.cluster_downtime_timezone
  lifecycle {
    ignore_changes = [start_time]
  }
}
