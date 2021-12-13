# Install helm chart for Bamboo Data Center.

resource "helm_release" "bamboo" {
  name       = "bamboo"
  namespace  = kubernetes_namespace.bamboo.metadata[0].name
  repository = "https://atlassian.github.io/data-center-helm-charts"
  chart      = "bamboo"
  version    = "0.0.1"

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
      volumes = {
        localHome = {
          persistentVolumeClaim = {
            create = true
          }
        }
        sharedHome = {
          customVolume = {
            persistentVolumeClaim = {
              claimName = kubernetes_persistent_volume_claim.atlassian-dc-bamboo-share-home-pvc.metadata[0].name
            }
          }
        }
      }
    }),
    local.ingress_settings,
    local.license_settings,
  ]
}

data "kubernetes_service" "bamboo" {
  depends_on = [helm_release.bamboo]
  metadata {
    name      = "bamboo"
    namespace = kubernetes_namespace.bamboo.metadata[0].name
  }
}