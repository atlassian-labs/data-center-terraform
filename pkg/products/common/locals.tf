locals {
  required_tags = {
  }

  vpc_name     = format("atlassian-dc-%s-vpc", var.environment_name)
  cluster_name = format("atlassian-dc-%s-cluster", var.environment_name)
}
