
locals {
  # When the framework get uninstalled, there is no appNode attribute for node_group and so next install will break
  # because eks is still is not created but terraform tries to evaluate the cluster_asg_name
  cluster_asg_name = try(module.eks.node_groups.appNodes.resources[0].autoscaling_groups[0].name, null)

  autoscaler_service_account_namespace = "kube-system"
  autoscaler_service_account_name      = "cluster-autoscaler-aws-cluster-autoscaler-chart"

  autoscaler_version = "9.25.0"

  ami_type = "AL2_x86_64"

  cluster_service_ipv4_cidr = "172.20.0.0/16"

  osquery_secret_region = var.osquery_secret_region != "" ? var.osquery_secret_region : var.region

  account_id = data.aws_caller_identity.current.account_id

  eks_node_policies = [ "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
                        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
                        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
                        "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
                        "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" ]
}
