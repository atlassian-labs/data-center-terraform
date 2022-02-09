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

  license_settings = yamlencode({
    jira = {
      license = {
        secretName = kubernetes_secret.license_secret.metadata[0].name
      }
    }
  })
}