# Create the elasticsearch based on Elasticsearch Helm charts (https://github.com/elastic/helm-charts/tree/main/elasticsearch)

resource "helm_release" "opensearch" {
  count = var.opensearch_enabled ? 1 : 0

  name       = "opensearch-${var.environment_name}"
  namespace  = var.namespace
  repository = "https://opensearch-project.github.io/helm-charts/"
  chart      = "opensearch"
#  version    = local.elasticsearch_helm_chart_version

  values = [
    yamlencode({
      singleNode = true

      extraEnvs = [
        { name = "OPENSEARCH_INITIAL_ADMIN_PASSWORD", value = local.opensearch_password },
        { name = "plugins.security.ssl.http.enabled", value = "false" }
      ]

      resources = {
        requests = {
          cpu    = var.opensearch_requests_cpu
          memory = var.opensearch_requests_memory
        }
      }
    })
  ]
}
