locals {
  # https://hello.atlassian.net/wiki/spaces/OBSERVABILITY/pages/140624694/Logging+pipeline+-+Sending+logs+to+Splunk#Kinesis-Stream-Details
  # e2e are deployed to almost a dozen of AWS regions, and we need to identify the closest available kinesis region.
  # If the region is found in any of the supported regions lists, it will be used as kinesis region in osquery flags.
  # Otherwise either the default european or non european region and role are used

  aws_sts_arn_role_eu     = var.kinesis_log_producers_role_arns["eu"]
  aws_sts_arn_role_non_eu = var.kinesis_log_producers_role_arns["non-eu"]

  kinesis_regions_eu     = ["eu-west-1", "eu-central-1"]
  kinesis_regions_non_eu = ["us-east-1", "us-west-1", "us-west-2", "ap-southeast-1", "ap-southeast-2"]

  region_contains_eu     = length(regexall("^eu-", var.region)) > 0 ? "eu-west-1" : ""
  region_matches_eu      = contains(local.kinesis_regions_eu, var.region) ? var.region : ""
  region_contains_non_eu = length(regexall("^ap-|us-|ca-|sa-|af-|me-", var.region)) > 0 ? "us-east-1" : ""
  region_matches_non_eu  = contains(local.kinesis_regions_non_eu, var.region) ? var.region : ""

  aws_sts_region = coalesce(local.region_matches_eu, local.region_matches_non_eu, local.region_contains_eu, local.region_contains_non_eu)

  aws_sts_arn_role = local.region_matches_eu != "" || local.region_contains_eu != "" ? local.aws_sts_arn_role_eu : local.aws_sts_arn_role_non_eu

  templates = fileset("${path.module}/templates", "*.tpl")

  osquery_templates     = var.osquery_secret_name != "" ? ["osquery/osquery.sh.tpl"] : []
  crowdstrike_templates = var.crowdstrike_secret_name != "" ? ["crowdstrike/crowdstrike.sh.tpl"] : []

  templates_all = concat(tolist(local.templates), local.osquery_templates, local.crowdstrike_templates)

  current_aws_region = data.aws_region.current.name

  user_content = [for tpl in local.templates_all : templatefile("${path.module}/templates/${tpl}", {
    account_id                    = data.aws_caller_identity.current.account_id
    aws_sts_region                = local.aws_sts_region
    osquery_secret_name           = var.osquery_secret_name
    osquery_secret_region         = var.osquery_secret_region
    osquery_version               = var.osquery_version
    env                           = var.osquery_env
    aws_sts_arn_role              = local.aws_sts_arn_role
    osquery_fleet_enrollment_host = var.osquery_fleet_enrollment_host
    falcon_sensor_version         = var.falcon_sensor_version
    aws_region                    = local.current_aws_region
    crowdstrike_aws_account_id    = var.crowdstrike_aws_account_id
    crowdstrike_secret_name       = var.crowdstrike_secret_name
  })]

  user_data = local.user_content != null ? base64encode(join("\n", concat(local.user_content, ["--==MYBOUNDARY==--"]))) : null
}
