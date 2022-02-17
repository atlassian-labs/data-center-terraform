locals {
  vpc_name       = format("atlas-%s-vpc", var.environment_name)
  cluster_name   = format("atlas-%s-cluster", var.environment_name)
  efs_name       = format("atlas-%s-efs", var.environment_name)
  ingress_domain = var.domain != null ? "${var.environment_name}.${var.domain}" : null

  storage_class_name = "efs-cs"

  # The value of OSQUERY_ENV that will be used to send logs to Splunk. It should not be something like “production”
  # or “prod-west2” but should instead relate to the product, platform, or team.
  osquery_env = "osquery_infrastructure_${local.cluster_name}"
}
