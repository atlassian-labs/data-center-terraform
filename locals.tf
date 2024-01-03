locals {
  cluster_name = format("atlas-%s-cluster", var.environment_name)
  namespace    = "atlassian"

  install_jira       = contains([for o in var.products : lower(o)], "jira")
  install_bitbucket  = contains([for o in var.products : lower(o)], "bitbucket")
  install_confluence = contains([for o in var.products : lower(o)], "confluence")
  install_bamboo     = contains([for o in var.products : lower(o)], "bamboo")
  install_crowd      = contains([for o in var.products : lower(o)], "crowd")

  database_settings = {
    jira = {
      db_allocated_storage    = var.jira_db_allocated_storage
      db_instance_class       = var.jira_db_instance_class
      db_iops                 = var.jira_db_iops
      db_major_engine_version = var.jira_db_major_engine_version
      db_master_username      = var.jira_db_master_username
      db_master_password      = var.jira_db_master_password
      db_name                 = var.jira_db_name
    }

    bitbucket = {
      db_allocated_storage    = var.bitbucket_db_allocated_storage
      db_instance_class       = var.bitbucket_db_instance_class
      db_iops                 = var.bitbucket_db_iops
      db_major_engine_version = var.bitbucket_db_major_engine_version
      db_master_username      = var.bitbucket_db_master_username
      db_master_password      = var.bitbucket_db_master_password
      db_name                 = var.bitbucket_db_name
    }

    crowd = {
      db_allocated_storage    = var.crowd_db_allocated_storage
      db_instance_class       = var.crowd_db_instance_class
      db_iops                 = var.crowd_db_iops
      db_major_engine_version = var.crowd_db_major_engine_version
      db_master_username      = var.crowd_db_master_username
      db_master_password      = var.crowd_db_master_password
      db_name                 = var.crowd_db_name
    }

    confluence = {
      db_allocated_storage    = var.confluence_db_allocated_storage
      db_instance_class       = var.confluence_db_instance_class
      db_iops                 = var.confluence_db_iops
      db_major_engine_version = var.confluence_db_major_engine_version
      db_master_username      = var.confluence_db_master_username
      db_master_password      = var.confluence_db_master_password
      db_name                 = var.confluence_db_name

    }

    bamboo = {
      db_allocated_storage    = var.bamboo_db_allocated_storage
      db_instance_class       = var.bamboo_db_instance_class
      db_iops                 = var.bamboo_db_iops
      db_major_engine_version = var.bamboo_db_major_engine_version
      db_master_username      = null
      db_master_password      = null
      db_name                 = var.bamboo_db_name
    }
  }

  nfs_server_settings = {
    jira = {
      nfs_requests_cpu        = var.jira_nfs_requests_cpu
      nfs_requests_memory     = var.jira_nfs_requests_memory
      nfs_limits_cpu          = var.jira_nfs_limits_cpu
      nfs_limits_memory       = var.jira_nfs_limits_memory
      shared_home_size        = var.jira_shared_home_size
      shared_home_snapshot_id = local.jira_ebs_snapshot_id
      cluster_service_ipv4    = "172.20.2.5"
    }
    confluence = {
      nfs_requests_cpu        = var.confluence_nfs_requests_cpu
      nfs_requests_memory     = var.confluence_nfs_requests_memory
      nfs_limits_cpu          = var.confluence_nfs_limits_cpu
      nfs_limits_memory       = var.confluence_nfs_limits_memory
      shared_home_size        = var.confluence_shared_home_size
      shared_home_snapshot_id = local.confluence_ebs_snapshot_id
      cluster_service_ipv4    = "172.20.2.4"
    }
    bitbucket = {
      nfs_requests_cpu        = var.bitbucket_nfs_requests_cpu
      nfs_requests_memory     = var.bitbucket_nfs_requests_memory
      nfs_limits_cpu          = var.bitbucket_nfs_limits_cpu
      nfs_limits_memory       = var.bitbucket_nfs_limits_memory
      shared_home_size        = var.bitbucket_shared_home_size
      shared_home_snapshot_id = local.bitbucket_ebs_snapshot_id
      cluster_service_ipv4    = "172.20.2.3"
    }
    bamboo = {
      nfs_requests_cpu        = var.bamboo_nfs_requests_cpu
      nfs_requests_memory     = var.bamboo_nfs_requests_memory
      nfs_limits_cpu          = var.bamboo_nfs_limits_cpu
      nfs_limits_memory       = var.bamboo_nfs_limits_memory
      shared_home_size        = var.bamboo_shared_home_size
      shared_home_snapshot_id = null
      cluster_service_ipv4    = "172.20.2.2"
    }
    crowd = {
      nfs_requests_cpu        = var.crowd_nfs_requests_cpu
      nfs_requests_memory     = var.crowd_nfs_requests_memory
      nfs_limits_cpu          = var.crowd_nfs_limits_cpu
      nfs_limits_memory       = var.crowd_nfs_limits_memory
      shared_home_size        = var.crowd_shared_home_size
      shared_home_snapshot_id = local.crowd_ebs_snapshot_id
      cluster_service_ipv4    = "172.20.2.6"
    }
  }

  # If Bitbucket is the only product to install then we don't need to create shared home
  shared_home_size = length(var.products) == 0 || (local.install_bitbucket && length(var.products) == 1) ? null : "5Gi"

  local_confluence_chart_path = var.local_helm_charts_path != "" && var.confluence_install_local_chart ? "${var.local_helm_charts_path}/confluence" : ""
  local_bitbucket_chart_path  = var.local_helm_charts_path != "" && var.bitbucket_install_local_chart ? "${var.local_helm_charts_path}/bitbucket" : ""
  local_jira_chart_path       = var.local_helm_charts_path != "" && var.jira_install_local_chart ? "${var.local_helm_charts_path}/jira" : ""
  local_bamboo_chart_path     = var.local_helm_charts_path != "" && var.bamboo_install_local_chart ? "${var.local_helm_charts_path}/bamboo" : ""
  local_agent_chart_path      = var.local_helm_charts_path != "" && var.bamboo_install_local_chart ? "${var.local_helm_charts_path}/bamboo-agent" : ""
  local_crowd_chart_path      = var.local_helm_charts_path != "" && var.crowd_install_local_chart ? "${var.local_helm_charts_path}/crowd" : ""

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

  jira_flavor_versions = local.snapshots_json != null ? contains([var.jira_image_repository], "atlassian/jira-servicemanagement") ? local.snapshots_json.jsm.versions : local.snapshots_json.jira.versions : null

  filtered_jira_snapshots = local.snapshots_json != null ? flatten([
    for version in local.jira_flavor_versions :
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

  rds_snapshots = {
    bitbucket  = length(compact(local.bitbucket_rds_snapshot)) > 0 ? compact(local.bitbucket_rds_snapshot)[0] : var.bitbucket_db_snapshot_id != null ? var.bitbucket_db_snapshot_id : null
    confluence = length(compact(local.confluence_rds_snapshot)) > 0 ? compact(local.confluence_rds_snapshot)[0] : var.confluence_db_snapshot_id != null ? var.confluence_db_snapshot_id : null
    crowd      = length(compact(local.crowd_rds_snapshot)) > 0 ? compact(local.crowd_rds_snapshot)[0] : var.crowd_db_snapshot_id != null ? var.crowd_db_snapshot_id : null
    jira       = length(compact(local.jira_rds_snapshot)) > 0 ? compact(local.jira_rds_snapshot)[0] : var.jira_db_snapshot_id != null ? var.jira_db_snapshot_id : null
    bamboo     = null
  }

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
