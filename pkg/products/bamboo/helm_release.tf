# Install helm chart for Bamboo Data Center.

resource "helm_release" "bamboo" {
  name       = "bamboo"
  namespace  = local.product_name
  repository = "https://atlassian.github.io/data-center-helm-charts"
  chart      = "bamboo"
  version    = "0.0.1"
  depends_on = [kubernetes_persistent_volume_claim.atlassian-dc-bamboo-share-home-pvc, kubernetes_namespace.bamboo]

  values = [
    yamlencode({
      bamboo = {
        resources = {
          jvm = {
            maxHeap = "512m"
            minHeap = "256m"
          }
          container = {
            requests = {
              cpu    = "1",
              memory = "1Gi"
            }
          }
        }
      }
      database = {
        type = "postgresql"
        url  = module.database.rds_jdbc_connection
        credentials = {
          secretName = kubernetes_secret.rds_secret.metadata[0].name
        }
      }
      ingress = {
        create = "true",
        host   = local.product_domain_name,
      },
    })
  ]
}