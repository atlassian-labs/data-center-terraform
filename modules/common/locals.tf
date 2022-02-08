locals {
  vpc_name       = format("atlas-%s-vpc", var.environment_name)
  cluster_name   = format("atlas-%s-cluster", var.environment_name)
  efs_name       = format("atlas-%s-efs", var.environment_name)
  ingress_domain = var.domain != null ? "${var.environment_name}.${var.domain}" : null

  storage_class_name = "efs-cs"
}
