data "aws_caller_identity" "current" {}

data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amazon-eks-node-1.21-v2022*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "nodegroup" {
  name                   = "${var.cluster_name}"
  description            = "${var.cluster_name} Nodegroup Launch Template"
  update_default_version = true
  user_data              = local.user_data
  instance_type          = var.instance_types[0]
  image_id               = data.aws_ami.eks_default.id
  vpc_security_group_ids = var.vpc_security_group_ids
  iam_instance_profile {
    name = var.aws_iam_instance_profile
  }
  tag_specifications {
    resource_type = "instance"
    tags = var.tags
  }
  tag_specifications {
    resource_type = "volume"
    tags = var.tags
  }
  lifecycle {
    create_before_destroy = true
  }
}
