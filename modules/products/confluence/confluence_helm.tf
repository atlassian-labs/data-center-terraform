# Install helm chart for Bamboo Data Center.

resource "helm_release" "confluence" {
  name       = local.product_name
  namespace  = kubernetes_namespace.confluence.metadata[0].name
  repository = local.helm_chart_repository
  chart      = local.product_name
  version    = local.confluence_helm_chart_version
  timeout    = 40 * 60 # dataset import can take a long time

  values = [
    yamlencode({
      confluence = {
        clustering = {
          enabled = true
        }
        resources = {
          jvm = {
            maxHeap = local.confluence_software_resources.maxHeap
            minHeap = local.confluence_software_resources.minHeap
          }
          container = {
            requests = {
              cpu    = local.confluence_software_resources.cpu
              memory = local.confluence_software_resources.mem
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
      fluentd = {
        enabled = true
        elasticsearch = {
          hostname = "elasticsearch-master"
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
              claimName = kubernetes_persistent_volume_claim.atlassian-dc-confluence-share-home-pvc.metadata[0].name
            }
          }
          subPath = "confluence"
        }
      }
    }),
    local.ingress_settings,
    local.license_settings,
  ]
}

data "kubernetes_service" "confluence" {
  depends_on = [helm_release.confluence]
  metadata {
    name      = local.product_name
    namespace = kubernetes_namespace.confluence.metadata[0].name
  }
}
