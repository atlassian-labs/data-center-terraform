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
    }
  }
}


// Manually add default tags to ASG due to the node group resource limitation(See: https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1558)
data "aws_default_tags" "current" {}

# data "aws_instances" "ec2" {
#   filter {
#     name   = "tag:eks:cluster-name"
#     values = [var.cluster_name]
#   }
# }

resource "aws_autoscaling_group_tag" "tag" {
  for_each               = data.aws_default_tags.current.tags
  autoscaling_group_name = module.eks.node_groups.appNodes.resources[0].autoscaling_groups[0].name

  tag {
    key                 = each.key
    value               = each.value
    propagate_at_launch = true
  }
}

# resource "aws_ec2_tag" "tag" {
#   for_each               = {for tag in local.ec2_formatted_tags : tag.iteration_id => tag}
#   resource_id = each.value.resource_id
#     key                 = each.value.tag_key
#     value               = each.value.tag_value
# }