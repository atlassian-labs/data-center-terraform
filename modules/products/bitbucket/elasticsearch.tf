# Create the elasticsearch based on Elasticsearch Helm charts (https://github.com/elastic/helm-charts/tree/main/elasticsearch)

resource "helm_release" "elasticsearch" {
  count = var.elasticsearch_endpoint == null ? 1 : 0

  name       = "${local.elasticsearch_name}-${var.environment_name}"
  namespace  = var.namespace
  repository = local.elasticsearch_helm_chart_repository
  chart      = "elasticsearch"
  version    = local.elasticsearch_helm_chart_version

  values = [
    yamlencode({
      name     = local.elasticsearch_name,
      imageTag = local.elasticsearch_helm_chart_version

      antiAffinity = local.elasticsearch_antiAffinity
      replicas     = var.elasticsearch_replicas,
      resources = {
        requests = {
          cpu    = var.elasticsearch_cpu
          memory = var.elasticsearch_mem
        }
      },
      volumeClaimTemplate = {
        resources = {
          requests = {
            storage = var.elasticsearch_storage
          }
        },
      }
    })
  ]
}
