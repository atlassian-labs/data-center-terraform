// Manually add default tags to ASG and EC2 after the initial provisioning due to the node group resource limitation(See: https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1558)
data "terraform_remote_state" "s3" {
  count   = var.state_type == "s3" ? 1 : 0
  backend = "s3"

  config = {
    region = var.region
    bucket = local.bucket_name
    key    = local.bucket_key
  }
}
data "terraform_remote_state" "local" {
  count = var.state_type == "local" ? 1 : 0

  backend = "local"

  config = {
    path = "../../../../terraform.tfstate"
  }
}

data "aws_default_tags" "current" {}

data "aws_instances" "ec2" {
  filter {
    name   = "tag:eks:cluster-name"
    values = [local.cluster_name]
  }
}

resource "aws_ec2_tag" "default_tag" {
  for_each    = { for tag in local.ec2_formatted_tags : tag.iteration_id => tag }
  resource_id = each.value.resource_id
  key         = each.value.tag_key
  value       = each.value.tag_value
}

resource "aws_autoscaling_group_tag" "tag" {
  for_each               = data.aws_default_tags.current.tags
  autoscaling_group_name = var.state_type == "s3" ? data.terraform_remote_state.s3[0].outputs.eks.cluster_asg_name : data.terraform_remote_state.local[0].outputs.eks.cluster_asg_name

  tag {
    key                 = each.key
    value               = each.value
    propagate_at_launch = true
  }
}