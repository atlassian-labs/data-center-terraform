locals {
  product_name = "jira"

  helm_chart_repository   = "https://atlassian.github.io/data-center-helm-charts"
  jira_helm_chart_version = var.jira_configuration["helm_version"]

  jira_software_resources = {
    "minHeap" : var.jira_configuration["min_heap"]
    "maxHeap" : var.jira_configuration["max_heap"]
    "cpu" : var.jira_configuration["cpu"]
    "mem" : var.jira_configuration["mem"]
  }

  rds_instance_name = format("atlas-%s-%s-db", var.environment_name, local.product_name)

  # if the domain wasn't provided we will start Jira with LoadBalancer service without ingress configuration
  use_domain          = length(var.ingress) == 1
  product_domain_name = local.use_domain ? "${local.product_name}.${var.ingress[0].ingress.domain}" : null
  # ingress settings for Bamboo service
  ingress_with_domain = yamlencode({
    ingress = {
      create = "true"
      host   = local.product_domain_name
    }
  })

  service_as_loadbalancer = yamlencode({
    jira = {
      service = {
        type = "LoadBalancer"
      }
    }
    ingress = {
      https = false
    }
  })

  ingress_settings = local.use_domain ? local.ingress_with_domain : local.service_as_loadbalancer

}