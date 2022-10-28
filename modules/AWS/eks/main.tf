data "aws_caller_identity" "current" {}


# resource "aws_iam_instance_profile" "worker_node_profile" {
#   name = "eugenetest"
#   role = module.eks.self_managed_node_groups.appNodes.iam_role_name
# }

# iam_role_additional_policies can have objects which arns need to be computed,
# thus attaching policies to worker node roles outside of eks
resource "aws_iam_role_policy_attachment" "laas" {
  for_each   = module.eks.self_managed_node_groups
  policy_arn = aws_iam_policy.laas[0].arn
  role       = each.value.iam_role_name
}

resource "aws_iam_role_policy_attachment" "fleet_enrollment_secret" {
  for_each   = module.eks.self_managed_node_groups
  policy_arn = aws_iam_policy.fleet_enrollment_secret[0].arn
  role       = each.value.iam_role_name
}


# resource "aws_iam_role_policy_attachment" "laas" {
#   policy_arn = aws_iam_policy.laas[0].arn
#   role       = aws_iam_role.self_managed_nodes_group.name
# }
#
# resource "aws_iam_role_policy_attachment" "fleet_enrollment_secret" {
#   policy_arn = aws_iam_policy.fleet_enrollment_secret[0].arn
#   role       = aws_iam_role.self_managed_nodes_group.name
# }
#
#
# resource "aws_iam_role_policy_attachment" "eks_worker_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.self_managed_nodes_group.name
# }
#
# resource "aws_iam_role_policy_attachment" "container_registry_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.self_managed_nodes_group.name
# }
#
# resource "aws_iam_role_policy_attachment" "ssm_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#   role       = aws_iam_role.self_managed_nodes_group.name
# }
#
# resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.self_managed_nodes_group.name
# }
#
# resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.eks_cluster.name
# }
#
# resource "aws_iam_role_policy_attachment" "eks_service_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
#   role       = aws_iam_role.eks_cluster.name
# }
#
# resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
#   role       = aws_iam_role.eks_cluster.name
# }

# module "nodegroup_launch_template" {
#   cluster_name                    = var.cluster_name
#   source                          = "./nodegroup_launch_template"
#   region                          = var.region
#   tags                            = var.tags
#   k8s_ca                          = module.eks.cluster_certificate_authority_data
#   api_server_endpoint             = module.eks.cluster_endpoint
#   instance_types                  = var.instance_types
#   osquery_secret_name             = var.osquery_secret_name
#   osquery_secret_region           = local.osquery_secret_region
#   osquery_env                     = var.osquery_env
#   osquery_version                 = var.osquery_version
#   kinesis_log_producers_role_arns = var.kinesis_log_producers_role_arns
#
#   vpc_security_group_ids = [aws_security_group.worker_nodes_sg.id]
#   aws_iam_instance_profile = aws_iam_instance_profile.self_managed_worker_nodes.id
# }

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.30.2"

  # Configure cluster
  cluster_version = "1.21"
  cluster_name    = var.cluster_name
  create_iam_role = true

  cluster_addons = {
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  # Self managed node groups will not automatically create the aws-auth configmap so we need to
  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true
  # iam_role_arn = aws_iam_role.self_managed_nodes_group.arn

  # Enables IAM roles for service accounts - required for autoscaler
  # https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
  enable_irsa = true

  # Networking
  vpc_id                    = var.vpc_id
  subnet_ids                = var.subnets
  cluster_service_ipv4_cidr = local.cluster_service_ipv4_cidr

# See: https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1748
# Need to open 8443 port. We open a wider range for now.
  node_security_group_additional_rules = {
    ingress_admission_webhook = {
      description                = "Nginx ingress controller admission webhook from master to nodes"
      protocol                   = "tcp"
      from_port                  = 8443
      to_port                    = 8443
      type                       = "ingress"
      source_cluster_security_group = true
    }
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  # Managed node group defaults
  self_managed_node_group_defaults = {
    ami_type  = local.ami_type
    disk_size = var.instance_disk_size
  }

  # Self-managed node group. We explicitly disable automatic launch template creation
  # to use a custom launch template with user data and resource_tags
  self_managed_node_groups = {
    appNodes = {
      name                         = "${var.cluster_name}"
      max_size                     = var.max_cluster_capacity
      desired_size                 = var.min_cluster_capacity
      min_size                     = var.min_cluster_capacity
      subnets                      = slice(var.subnets, 0, 1)
      instance_type                = var.instance_types[0]
      capacity_type                = "ON_DEMAND"
      autoscaling_group_tags       = var.tags
      pre_bootstrap_user_data      = local.user_data
      # create_launch_template       = false
      # launch_template_name         = "${var.cluster_name}"
      # launch_template_version      = module.nodegroup_launch_template.version
      iam_role_additional_policies = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
      # create_iam_instance_profile = false
    }
  }
}

resource "aws_autoscaling_group_tag" "this" {
  for_each               = var.tags
  autoscaling_group_name = module.eks.self_managed_node_groups.appNodes.autoscaling_group_id

  tag {
    key                 = each.key
    value               = each.value
    propagate_at_launch = true
  }
}

data "aws_default_tags" "current" {}

data "aws_instances" "worker_nodes" {

  instance_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

#   filter {
#   name   = "tag:eks:cluster-name"
#   values = [var.cluster_name]
# }
  instance_state_names = ["running"]
}

resource "aws_ec2_tag" "default_tag" {
  for_each    = { for tag in local.ec2_formatted_tags : tag.iteration_id => tag }
  resource_id = each.value.resource_id
  key         = each.value.tag_key
  value       = each.value.tag_value
  depends_on = [
    module.eks
  ]
}
