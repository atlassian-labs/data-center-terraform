locals {
  product_name = "jira"

  use_local_chart         = fileexists("${var.local_jira_chart_path}/Chart.yaml")
  helm_chart_repository   = local.use_local_chart ? null : "https://atlassian.github.io/data-center-helm-charts"
  jira_helm_chart_name    = local.use_local_chart ? var.local_jira_chart_path : local.product_name
  jira_helm_chart_version = local.use_local_chart ? null : var.jira_configuration["helm_version"]

  jira_software_resources = {
    "minHeap" : var.jira_configuration["min_heap"]
    "maxHeap" : var.jira_configuration["max_heap"]
    "cpu" : var.jira_configuration["cpu"]
    "mem" : var.jira_configuration["mem"]
    "reservedCodeCache" : var.jira_configuration["reserved_code_cache"]
  }

  domain_supplied          = var.ingress.outputs.domain != null ? true : false
  product_domain_name      = local.domain_supplied ? "${local.product_name}.${var.ingress.outputs.domain}" : null
  ageOfUsableIndexSnapshot = 24 * 365 * 10 # 10 years

  # ingress settings for Jira service
  ingress_settings = yamlencode({
    ingress = {
      create = "true"
      host   = local.domain_supplied ? "${local.product_name}.${var.ingress.outputs.domain}" : var.ingress.outputs.lb_hostname
      https  = local.domain_supplied ? true : false
      path   = local.domain_supplied ? null : "/${local.product_name}"
    }
  })

  jira_ingress_url = local.domain_supplied ? "https://${local.product_domain_name}" : "http://${var.ingress.outputs.lb_hostname}/${local.product_name}"

  context_path_settings = !local.domain_supplied ? yamlencode({
    jira = {
      service = {
        contextPath = "/${local.product_name}"
      }
    }
  }) : yamlencode({})

  version_tag = var.version_tag != null ? yamlencode({
    image = {
      tag = var.version_tag
    }
  }) : yamlencode({})

  # After restoring the snapshot of the Jira database, a re-index is required. To avoid interruption in the Jira
  # service we should exclude indexing status from the health check process.
  # For more info see: https://jira.atlassian.com/browse/JRASERVER-66970
  ignore_index_check = var.db_snapshot_id != null ? ["-Dcom.atlassian.jira.status.index.check=false"] : []

  # By default, Jira accepts an index snapshot taken within 24hours. In order to use snapshot older than 24hours we need to update following property value.
  # It is set to 10 years.
  reuse_old_index_snapshot = var.shared_home_snapshot_id != null ? ["-Dcom.atlassian.jira.startup.max.age.of.usable.index.snapshot.in.hours=${local.ageOfUsableIndexSnapshot}"] : []

  # DC App Performance Toolkit analytics
  dcapt_analytics_property = ["-Dcom.atlassian.dcapt.deployment=terraform"]

  nfs_cluster_service_ipv4 = "172.20.2.5"
}
