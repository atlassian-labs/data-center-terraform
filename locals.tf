locals {
  cluster_name = format("atlas-%s-cluster", var.environment_name)
  namespace    = "atlassian"

  install_jira       = contains([for o in var.products : lower(o)], "jira")
  install_bitbucket  = contains([for o in var.products : lower(o)], "bitbucket")
  install_confluence = contains([for o in var.products : lower(o)], "confluence")
  install_bamboo     = contains([for o in var.products : lower(o)], "bamboo")
  install_crowd      = contains([for o in var.products : lower(o)], "crowd")

  # If Bitbucket is the only product to install then we don't need to create shared home
  shared_home_size = length(var.products) == 0 || (local.install_bitbucket && length(var.products) == 1) ? null : "5Gi"

  local_confluence_chart_path = var.local_helm_charts_path != "" && var.confluence_install_local_chart ? "${var.local_helm_charts_path}/confluence" : ""
  local_bitbucket_chart_path  = var.local_helm_charts_path != "" && var.bitbucket_install_local_chart ? "${var.local_helm_charts_path}/bitbucket" : ""
  local_jira_chart_path       = var.local_helm_charts_path != "" && var.jira_install_local_chart ? "${var.local_helm_charts_path}/jira" : ""
  local_bamboo_chart_path     = var.local_helm_charts_path != "" && var.bamboo_install_local_chart ? "${var.local_helm_charts_path}/bamboo" : ""
  local_agent_chart_path      = var.local_helm_charts_path != "" && var.bamboo_install_local_chart ? "${var.local_helm_charts_path}/bamboo-agent" : ""
  local_crowd_chart_path      = var.local_helm_charts_path != "" && var.crowd_install_local_chart ? "${var.local_helm_charts_path}/crowd" : ""

  #  snapshots_json = var.snapshots_json_file_path != "" ? jsondecode(file(var.snapshots_json_file_path)) : jsondecode("{\"jira\": {\"versions\":[]},\"confluence\": {\"versions\":[]},\"crowd\": {\"versions\":[]},\"bitbucket\": {\"versions\":[]}}")
  snapshots_json = var.snapshots_json_file_path != "" ? jsondecode(file(var.snapshots_json_file_path)) : null

  filtered_bitbucket_snapshots = local.snapshots_json != null ? flatten([
    for version in local.snapshots_json.bitbucket.versions :
    [for snapshot in version.data :
      merge({ version = version.version }, snapshot)
    ]
  ]) : []

  bitbucket_rds_snapshot = local.snapshots_json != null ? [
    for snapshot in local.filtered_bitbucket_snapshots :
    snapshot.type == "rds" && snapshot.size == var.bitbucket_dataset_size && snapshot.version == var.bitbucket_version_tag ? snapshot.snapshots[0][var.region] : ""
  ] : []

  bitbucket_ebs_snapshot = local.snapshots_json != null ? [
    for snapshot in local.filtered_bitbucket_snapshots :
    snapshot.type == "ebs" && snapshot.size == var.bitbucket_dataset_size && snapshot.version == var.bitbucket_version_tag ? snapshot.snapshots[0][var.region] : ""
  ] : []

  filtered_confluence_snapshots = local.snapshots_json != null ? flatten([
    for version in local.snapshots_json.confluence.versions :
    [for snapshot in version.data :
      merge({ version = version.version }, snapshot)
    ]
  ]) : []

  confluence_rds_snapshot = local.snapshots_json != null ? [
    for snapshot in local.filtered_confluence_snapshots :
    snapshot.type == "rds" && snapshot.size == var.confluence_dataset_size && snapshot.version == var.confluence_version_tag ? snapshot.snapshots[0][var.region] : ""
  ] : []

  confluence_ebs_snapshot = local.snapshots_json != null ? [
    for snapshot in local.filtered_confluence_snapshots :
    snapshot.type == "ebs" && snapshot.size == var.confluence_dataset_size && snapshot.version == var.confluence_version_tag ? snapshot.snapshots[0][var.region] : ""
  ] : []

  confluence_build_numbers = local.snapshots_json != null ? flatten([
    for version in local.snapshots_json.confluence.versions :
    version.version == var.confluence_version_tag ? version.build_number : ""
  ]) : []

  filtered_crowd_snapshots = local.snapshots_json != null ? flatten([
    for version in local.snapshots_json.crowd.versions :
    [for snapshot in version.data :
      merge({ version = version.version }, snapshot)
    ]
  ]) : []

  crowd_rds_snapshot = local.snapshots_json != null ? [
    for snapshot in local.filtered_crowd_snapshots :
    snapshot.type == "rds" && snapshot.size == var.crowd_dataset_size && snapshot.version == var.crowd_version_tag ? snapshot.snapshots[0][var.region] : ""
  ] : []

  crowd_ebs_snapshot = local.snapshots_json != null ? [
    for snapshot in local.filtered_crowd_snapshots :
    snapshot.type == "ebs" && snapshot.size == var.crowd_dataset_size && snapshot.version == var.crowd_version_tag ? snapshot.snapshots[0][var.region] : ""
  ] : []

  crowd_build_numbers = local.snapshots_json != null ? flatten([
    for version in local.snapshots_json.crowd.versions :
    version.version == var.crowd_version_tag ? version.build_number : ""
  ]) : []

  filtered_jira_snapshots = local.snapshots_json != null ? flatten([
    for version in local.snapshots_json.jira.versions :
    [for snapshot in version.data :
      merge({ version = version.version }, snapshot)
    ]
  ]) : []

  jira_rds_snapshot = local.snapshots_json != null ? [
    for snapshot in local.filtered_jira_snapshots :
    snapshot.type == "rds" && snapshot.size == var.jira_dataset_size && snapshot.version == var.jira_version_tag ? snapshot.snapshots[0][var.region] : ""
  ] : []

  jira_ebs_snapshot = local.snapshots_json != null ? [
    for snapshot in local.filtered_jira_snapshots :
    snapshot.type == "ebs" && snapshot.size == var.jira_dataset_size && snapshot.version == var.jira_version_tag ? snapshot.snapshots[0][var.region] : ""
  ] : []

  jira_rds_snapshot_id = length(compact(local.jira_rds_snapshot)) > 0 ? compact(local.jira_rds_snapshot)[0] : var.jira_db_snapshot_id != null ? var.jira_db_snapshot_id : null
  jira_ebs_snapshot_id = length(compact(local.jira_ebs_snapshot)) > 0 ? compact(local.jira_ebs_snapshot)[0] : var.jira_shared_home_snapshot_id != null ? var.jira_shared_home_snapshot_id : null

  confluence_rds_snapshot_id          = length(compact(local.confluence_rds_snapshot)) > 0 ? compact(local.confluence_rds_snapshot)[0] : var.confluence_db_snapshot_id != null ? var.confluence_db_snapshot_id : null
  confluence_ebs_snapshot_id          = length(compact(local.confluence_ebs_snapshot)) > 0 ? compact(local.confluence_ebs_snapshot)[0] : var.confluence_shared_home_snapshot_id != null ? var.confluence_shared_home_snapshot_id : null
  confluence_db_snapshot_build_number = length(compact(local.confluence_build_numbers)) > 0 ? compact(local.confluence_build_numbers)[0] : var.confluence_db_snapshot_build_number != null ? var.confluence_db_snapshot_build_number : null

  crowd_rds_snapshot_id          = length(compact(local.crowd_rds_snapshot)) > 0 ? compact(local.crowd_rds_snapshot)[0] : var.crowd_db_snapshot_id != null ? var.crowd_db_snapshot_id : null
  crowd_ebs_snapshot_id          = length(compact(local.crowd_ebs_snapshot)) > 0 ? compact(local.crowd_ebs_snapshot)[0] : var.crowd_shared_home_snapshot_id != null ? var.crowd_shared_home_snapshot_id : null
  crowd_db_snapshot_build_number = length(compact(local.crowd_build_numbers)) > 0 ? compact(local.crowd_build_numbers)[0] : var.crowd_db_snapshot_build_number != null ? var.crowd_db_snapshot_build_number : null

  bitbucket_rds_snapshot_id = length(compact(local.bitbucket_rds_snapshot)) > 0 ? compact(local.bitbucket_rds_snapshot)[0] : var.bitbucket_db_snapshot_id != null ? var.bitbucket_db_snapshot_id : null
  bitbucket_ebs_snapshot_id = length(compact(local.bitbucket_ebs_snapshot)) > 0 ? compact(local.bitbucket_ebs_snapshot)[0] : var.bitbucket_shared_home_snapshot_id != null ? var.bitbucket_shared_home_snapshot_id : null

}
