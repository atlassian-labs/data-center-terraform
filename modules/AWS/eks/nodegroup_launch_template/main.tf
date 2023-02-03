data "aws_caller_identity" "current" {}

resource "aws_launch_template" "nodegroup" {
  name                   = "${var.cluster_name}-launch-template"
  description            = "${var.cluster_name} Nodegroup Launch Template"
  update_default_version = true
  user_data              = local.user_data
  instance_type          = var.instance_types[0]
  
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.instance_disk_size
      volume_type           = "gp2"
      delete_on_termination = true
    }
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
