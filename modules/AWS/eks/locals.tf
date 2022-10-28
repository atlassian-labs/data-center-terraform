
locals {
  # When the framework get uninstalled, there is no appNode attribute for node_group and so next install will break
  # because eks is still is not created but terraform tries to evaluate the cluster_asg_name
  cluster_asg_name = try(module.eks.node_groups.appNodes.resources[0].autoscaling_groups[0].name, null)

  ec2_formatted_tags = flatten([for id in data.aws_instances.worker_nodes.ids : [for key, value in data.aws_default_tags.current.tags : {
    tag_key : key
    tag_value : value
    resource_id : id
    iteration_id : "${id}-${key}"
    }
  ]])

  autoscaler_service_account_namespace = "kube-system"
  autoscaler_service_account_name      = "cluster-autoscaler-aws-cluster-autoscaler-chart"

  autoscaler_version = "9.16.0"

  ami_type = "AL2_x86_64"

  cluster_service_ipv4_cidr = "172.20.0.0/16"

  workers_additional_policies = var.osquery_secret_name != "" ? [aws_iam_policy.laas[0].arn,aws_iam_policy.fleet_enrollment_secret[0].arn, "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"] : ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]

  osquery_secret_region = var.osquery_secret_region != "" ? var.osquery_secret_region : var.region

  account_id = data.aws_caller_identity.current.account_id

  osquery_version = "5.5.1"
  # https://hello.atlassian.net/wiki/spaces/OBSERVABILITY/pages/140624694/Logging+pipeline+-+Sending+logs+to+Splunk#Kinesis-Stream-Details
  # e2e are deployed to almost a dozen of AWS regions, and we need to identify the closest available kinesis region.
  # If the region is found in any of the supported regions lists, it will be used as kinesis region in osquery flags.
  # Otherwise either the default european or non european region and role are used

  aws_sts_arn_role_eu       = "${var.kinesis_log_producers_role_arns["eu"]}"
  aws_sts_arn_role_non_eu   = "${var.kinesis_log_producers_role_arns["non-eu"]}"

  kinesis_regions_eu        = ["eu-west-1", "eu-central-1"]
  kinesis_regions_non_eu    = ["us-east-1", "us-west-1", "us-west-2", "ap-southeast-1", "ap-southeast-2"]

  region_contains_eu        = length(regexall("^eu-", var.region)) > 0 ? "eu-west-1" : ""
  region_matches_eu         = contains(local.kinesis_regions_eu, var.region) ? var.region : ""
  region_contains_non_eu    = length(regexall("^ap-|us-|ca-|sa-|af-|me-", var.region)) > 0 ? "us-east-1" : ""
  region_matches_non_eu     = contains(local.kinesis_regions_non_eu, var.region) ? var.region : ""

  aws_sts_region            = coalesce(local.region_matches_eu, local.region_matches_non_eu, local.region_contains_eu, local.region_contains_non_eu)

  aws_sts_arn_role          = local.region_matches_eu != "" || local.region_contains_eu != "" ? local.aws_sts_arn_role_eu : local.aws_sts_arn_role_non_eu

  templates = fileset("${path.module}/templates", "*.tpl")

  templates_all = var.osquery_secret_name != "" ? concat(tolist(local.templates), ["osquery/osquery.sh.tpl"]) : local.templates

  user_content              = [ for tpl in local.templates_all : templatefile("${path.module}/templates/${tpl}", {
    cluster_name                    = var.cluster_name
    k8s_ca                          = var.k8s_ca
    api_server_endpoint             = var.api_server_endpoint
    account_id                      = data.aws_caller_identity.current.account_id
    aws_sts_region                  = local.aws_sts_region
    osquery_secret_name             = var.osquery_secret_name
    osquery_secret_region           = local.osquery_secret_region
    osquery_version                 = var.osquery_version
    env                             = var.osquery_env
    aws_sts_arn_role                = local.aws_sts_arn_role
    kinesis_log_producers_role_arns = var.kinesis_log_producers_role_arns
    })]

  user_data = local.user_content != null ? join("\n",local.user_content) : null

}
