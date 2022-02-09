# Install helm chart for confluence Data Center.
resource "helm_release" "confluence" {
  name       = local.product_name
  namespace  = var.namespace
  repository = local.helm_chart_repository
  chart      = local.confluence_helm_chart_name
  version    = local.confluence_helm_chart_version
  timeout    = 10 * 60

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
    local.synchrony_settings,
    local.ingress_settings,
    local.license_settings,
  ]
}

data "kubernetes_service" "confluence" {
  depends_on = [helm_release.confluence]
  metadata {
    name      = local.product_name
    namespace = var.namespace
  }
}
