locals {
  vpc_name     = format("atlassian-dc-%s-vpc", var.environment_name)
  cluster_name = format("atlassian-dc-%s-cluster", var.environment_name)
  efs_name     = format("atlassian-dc-%s-efs", var.environment_name)
}
