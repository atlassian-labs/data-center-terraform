data "aws_caller_identity" "current" {}

resource "aws_launch_template" "nodegroup" {
  name                   = "${var.cluster_name}-launch-template"
  description            = "${var.cluster_name} Nodegroup Launch Template"
  update_default_version = true
  user_data              = local.user_data
  instance_type          = var.instance_types[0]
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
