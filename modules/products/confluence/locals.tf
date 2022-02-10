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

  # if the domain wasn't provided we will start confluence with LoadBalancer service without ingress configuration
  use_domain          = length(var.ingress) == 1
  product_domain_name = local.use_domain ? "${local.product_name}.${var.ingress[0].ingress.domain}" : null
  # ingress settings for confluence service
  ingress_with_domain = yamlencode({
    ingress = {
      create = "true"
      host   = local.product_domain_name
    }
  })

  service_as_loadbalancer = yamlencode({
    confluence = {
      service = {
        type = "LoadBalancer"
      }
    }
    ingress = {
      https = false
    }
  })

  ingress_settings = local.use_domain ? local.ingress_with_domain : local.service_as_loadbalancer

  license_settings = var.confluence_configuration["license"] != null ? yamlencode({
    confluence = {
      license = {
        secretName = kubernetes_secret.license_secret.metadata[0].name
      }
    }
  }) : yamlencode({})

  # if domain is not provided, a new LB is created for Confluence service
  confluence_ingress_url = local.use_domain ? "https://${local.product_domain_name}" : "http://${data.kubernetes_service.confluence.status[0].load_balancer[0].ingress[0].hostname}"

  # if domain is not provided, a new LB is created for Synchrony service
  synchrony_ingress_url = local.use_domain ? "${local.confluence_ingress_url}/synchrony" : "Synchrony is not available"

  synchrony_settings_stanza = local.use_domain ? yamlencode({
    synchrony = {
      enabled    = true
      ingressUrl = "https://${local.product_domain_name}/synchrony"
    }
  }) : yamlencode({})
}
