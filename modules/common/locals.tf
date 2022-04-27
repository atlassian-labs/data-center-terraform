locals {
  vpc_name       = format("atlas-%s-vpc", var.environment_name)
  cluster_name   = format("atlas-%s-cluster", var.environment_name)
  ingress_domain = var.domain != null ? "${var.environment_name}.${var.domain}" : null
}
