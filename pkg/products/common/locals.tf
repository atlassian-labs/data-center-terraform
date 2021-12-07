locals {
  vpc_name       = format("atlassian-dc-%s-vpc", var.environment_name)
  cluster_name   = substr(format("atlassian-dc-%s-cluster", var.environment_name), 0, 38) # Max length for EKS Cluster name is 38 characters
  efs_name       = format("atlassian-dc-%s-efs", var.environment_name)
  ingress_domain = var.domain != null ? "${var.environment_name}.${var.domain}" : null
}
