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
      path   = local.domain_supplied ? null : "/confluence"
    }
  })

  context_path_settings = !local.domain_supplied ? yamlencode({
    confluence = {
      service = {
        contextPath = "/confluence"
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

  # if domain is not provided, a new LB is created for Confluence service
  confluence_ingress_url = local.domain_supplied ? "https://${local.product_domain_name}" : "http://${var.ingress.outputs.lb_hostname}/confluence"

  # if domain is not provided, a new LB is created for Synchrony service
  synchrony_ingress_url = local.domain_supplied ? "${local.confluence_ingress_url}/synchrony" : "http://${var.ingress.outputs.lb_hostname}/synchrony"

  synchrony_settings_stanza = local.domain_supplied ? yamlencode({
    synchrony = {
      enabled    = true
      ingressUrl = "https://${local.product_domain_name}/synchrony"
    }
    }) : yamlencode({
    synchrony = {
      enabled    = true
      ingressUrl = "https://localhost/synchrony" # this is a dummy url that needs to be updated after the synchrony service is created
      service = {
        type = "LoadBalancer"
      }
    }
  })

  # Confluence version tag
  version_tag = var.version_tag != null ? yamlencode({
    image = {
      tag = var.version_tag
    }
  }) : yamlencode({})
}
