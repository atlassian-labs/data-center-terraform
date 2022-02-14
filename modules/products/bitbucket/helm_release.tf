# Install helm chart for Jira Data Center.

resource "helm_release" "bitbucket" {
  name       = local.product_name
  namespace  = var.namespace
  repository = local.helm_chart_repository
  chart      = local.product_name
  version    = local.bitbucket_helm_chart_version

  values = [
    yamlencode({
      replicaCount = 1,
      bitbucket = {
        clustering = {
          enabled = true
        }
        resources = {
          jvm = {
            maxHeap           = local.bitbucket_software_resources.maxHeap
            minHeap           = local.bitbucket_software_resources.minHeap
            reservedCodeCache = local.bitbucket_software_resources.reservedCodeCache
          }
          container = {
            requests = {
              cpu    = local.bitbucket_software_resources.cpu
              memory = local.bitbucket_software_resources.mem
            }
          }
        }
      }
      database = {
        type   = "postgres72"
        url    = module.database.rds_jdbc_connection
        driver = "org.postgresql.Driver"
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
              claimName = var.pvc_claim_name
            }
          }
          subPath = local.product_name
        }
      }
    }),
    local.ingress_settings,
  ]
}

data "kubernetes_service" "bitbucket" {
  depends_on = [helm_release.bitbucket]
  metadata {
    name      = local.product_name
    namespace = var.namespace
  }
}