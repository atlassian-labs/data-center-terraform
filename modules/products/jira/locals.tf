locals {
  product_name = "jira"

  helm_chart_repository   = "https://atlassian.github.io/data-center-helm-charts"
  jira_helm_chart_version = var.jira_configuration["helm_version"]

  jira_software_resources = {
    "minHeap" : var.jira_configuration["min_heap"]
    "maxHeap" : var.jira_configuration["max_heap"]
    "cpu" : var.jira_configuration["cpu"]
    "mem" : var.jira_configuration["mem"]
    "reservedCodeCache" : var.jira_configuration["reserved_code_cache"]
  }

  rds_instance_id = format("atlas-%s-%s-db", var.environment_name, local.product_name)

  domain_supplied     = var.ingress.outputs.domain != null ? true : false
  product_domain_name = local.domain_supplied ? "${local.product_name}.${var.ingress.outputs.domain}" : null

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

  # By default, Jira accepts an index snapshot taken within 24hours. In order to use snapshot older than 24hours we need to update following property value.
  # It is set to 10 years.
  reuse_old_index_snapshot = var.shared_home_snapshot_id != null ? yamlencode({
    jira = {
      additionalJvmArgs = ["-Dcom.atlassian.jira.startup.max.age.of.usable.index.snapshot.in.hours=87600"]
    }
  }) : yamlencode({})
}