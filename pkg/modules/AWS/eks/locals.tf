
locals {
  cluster_asg_name = try(module.eks.node_groups.appNodes.resources[0].autoscaling_groups[0].name, null)
}