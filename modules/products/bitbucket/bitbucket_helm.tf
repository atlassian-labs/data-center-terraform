# Install helm chart for Bamboo Data Center.

resource "helm_release" "bitbucket" {
  name       = local.product_name
  namespace  = kubernetes_namespace.bitbucket.metadata[0].name
  repository = local.helm_chart_repository
  chart      = local.product_name
  version    = local.bitbucket_helm_chart_version
  timeout    = 40 * 60 # dataset import can take a long time

  values = [
    yamlencode({
      replicaCount = 1,
      bitbucket = {
        elasticSearch = {
          baseUrl = "http://elasticsearch-master.monitoring.svc.cluster.local:9200/"
        }
        clustering = {
          enabled = true
        }
        resources = {
          jvm = {
            maxHeap = local.bitbucket_software_resources.maxHeap
            minHeap = local.bitbucket_software_resources.minHeap
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
        url    = module.database.rds_jdbc_connection
        driver = "org.postgresql.Driver"
        credentials = {
          secretName = kubernetes_secret.rds_secret.metadata[0].name
        }
      }
      fluentd = {
        enabled = true
        elasticsearch = {
          hostname = "elasticsearch-master.elasticsearch.svc.cluster.local"
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
              claimName = kubernetes_persistent_volume_claim.atlassian-dc-bitbucket-share-home-pvc.metadata[0].name
            }
          }
          subPath = "bitbucket"
        }
      }
    }),
    local.ingress_settings,
    local.license_settings,
    local.admin_settings,
  ]
}

data "kubernetes_service" "bitbucket" {
  depends_on = [helm_release.bitbucket]
  metadata {
    name      = local.product_name
    namespace = kubernetes_namespace.bitbucket.metadata[0].name
  }
}
