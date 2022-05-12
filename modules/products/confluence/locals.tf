locals {
  product_name = "confluence"

  # Install local confluence helm charts if local path is provided
  use_local_chart = fileexists("${var.local_confluence_chart_path}/Chart.yaml")

  helm_chart_repository         = local.use_local_chart ? null : "https://atlassian.github.io/data-center-helm-charts"
  confluence_helm_chart_name    = local.use_local_chart ? var.local_confluence_chart_path : local.product_name
  confluence_helm_chart_version = local.use_local_chart ? null : var.confluence_configuration["helm_version"]

  confluence_software_resources = {
    "minHeap" : var.confluence_configuration["min_heap"]
    "maxHeap" : var.confluence_configuration["max_heap"]
    "cpu" : var.confluence_configuration["cpu"]
    "mem" : var.confluence_configuration["mem"]
  }

  rds_instance_name = format("atlas-%s-%s-db", var.environment_name, local.product_name)

  domain_supplied     = var.ingress.outputs.domain != null ? true : false
  product_domain_name = local.domain_supplied ? "${local.product_name}.${var.ingress.outputs.domain}" : null

  # ingress settings for confluence service
  ingress_settings = yamlencode({
    ingress = {
      create = "true"
      host   = local.domain_supplied ? "${local.product_name}.${var.ingress.outputs.domain}" : var.ingress.outputs.lb_hostname
      https  = local.domain_supplied ? true : false
      path   = local.domain_supplied ? null : "/${local.product_name}"
    }
  })

  context_path_settings = !local.domain_supplied ? yamlencode({
    confluence = {
      service = {
        contextPath = "/${local.product_name}"
      }
    }
  }) : yamlencode({})

  license_settings = var.confluence_configuration["license"] != null ? yamlencode({
    confluence = {
      license = {
        secretName = kubernetes_secret.license_secret.metadata[0].name
      }
    }
  }) : yamlencode({})

  confluence_ingress_url = local.domain_supplied ? "https://${local.product_domain_name}" : "http://${var.ingress.outputs.lb_hostname}/${local.product_name}"

  synchrony_ingress_url = local.domain_supplied ? "${local.confluence_ingress_url}/synchrony" : "http://${var.ingress.outputs.lb_hostname}/${local.product_name}/synchrony"

  synchrony_settings_stanza = yamlencode({
    synchrony = {
      enabled    = true
      ingressUrl = local.synchrony_ingress_url
    }
  })

  # Confluence version tag
  version_tag = var.version_tag != null ? yamlencode({
    image = {
      tag = var.version_tag
    }
  }) : yamlencode({})

  # Provide additional environment variables to Confluence Helm chart to skip setup wizard when restoring database from snapshot.
  db_restore_env_vars = var.db_snapshot_id != null ? yamlencode({
    confluence = {
      additionalEnvironmentVariables = [
        {
          name  = "ATL_SETUP_STEP",
          value = "complete"
        },
        {
          name  = "ATL_SETUP_TYPE",
          value = "cluster"
        },
        {
          name  = "ATL_BUILD_NUMBER",
          value = var.db_snapshot_build_number
        },
        {
          name  = "ATL_SNAPSHOT_USED",
          value = "true"
        },
      ]
    }
  }) : yamlencode({})

  # DC App Performance Toolkit analytics
  dcapt_analytics_property = ["-Dcom.atlassian.dcapt.deployment=terraform"]
}
