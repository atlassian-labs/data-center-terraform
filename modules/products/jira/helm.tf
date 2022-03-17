# Install helm chart for Jira Data Center.

resource "helm_release" "jira" {
  name       = local.product_name
  namespace  = var.namespace
  repository = local.helm_chart_repository
  chart      = local.product_name
  version    = local.jira_helm_chart_version
  timeout    = 10 * 60 # autoscaler potentially needs to scale up the cluster

  values = [
    yamlencode({
      replicaCount = var.replica_count,
      jira = {
        clustering = {
          enabled = true
        }
        resources = {
          jvm = {
            maxHeap           = local.jira_software_resources.maxHeap
            minHeap           = local.jira_software_resources.minHeap
            reservedCodeCache = local.jira_software_resources.reservedCodeCache
          }
          container = {
            requests = {
              cpu    = local.jira_software_resources.cpu
              memory = local.jira_software_resources.mem
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
          resources = {
            requests = {
              storage = var.local_home_size
            }
          }
        }
        sharedHome = {
          customVolume = {
            persistentVolumeClaim = {
              claimName = var.pvc_claim_name
            }
          }
          subPath = "${local.product_name}-${random_string.random.result}"
        }
      }
    }),
    local.ingress_settings,
    local.version_tag,
  ]
}

data "kubernetes_service" "jira" {
  depends_on = [helm_release.jira]
  metadata {
    name      = local.product_name
    namespace = var.namespace
  }
}

resource "random_string" "random" {
  length  = 10
  special = false
  number  = true
}