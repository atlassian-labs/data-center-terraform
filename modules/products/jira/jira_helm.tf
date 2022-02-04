# Install helm chart for Bamboo Data Center.

resource "helm_release" "jira" {
  name       = local.product_name
  namespace  = kubernetes_namespace.jira.metadata[0].name
  repository = local.helm_chart_repository
  chart      = local.product_name
  version    = local.jira_helm_chart_version
  timeout    = 40 * 60 # dataset import can take a long time

  values = [
    yamlencode({
      replicaCount = 1,
      jira = {
        clustering = {
          enabled = true
        }
        resources = {
          jvm = {
            maxHeap = local.jira_software_resources.maxHeap
            minHeap = local.jira_software_resources.minHeap
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
              claimName = kubernetes_persistent_volume_claim.atlassian-dc-jira-share-home-pvc.metadata[0].name
            }
          }
          subPath = "jira"
        }
      }
    }),
    local.ingress_settings,
    local.license_settings,
  ]
}

data "kubernetes_service" "jira" {
  depends_on = [helm_release.jira]
  metadata {
    name      = local.product_name
    namespace = kubernetes_namespace.jira.metadata[0].name
  }
}
