# Install helm chart for Bamboo Data Center.

resource "helm_release" "bamboo" {
  depends_on = [kubernetes_job.import_dataset]
  name       = "bamboo"
  namespace  = kubernetes_namespace.bamboo.metadata[0].name
  repository = local.helm_chart_repository
  chart      = "bamboo"
  version    = local.helm_chart_version
  timeout    = 40 * 60 # dataset import can take a long time

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
    local.admin_settings,
    local.unattended_setup_setting,
    local.security_token_setting,
    local.dataset_settings,
  ]
}

data "kubernetes_service" "bamboo" {
  depends_on = [helm_release.bamboo]
  metadata {
    name      = "bamboo"
    namespace = kubernetes_namespace.bamboo.metadata[0].name
  }
}

resource "helm_release" "bamboo_agent" {
  name       = "bamboo-agent"
  namespace  = kubernetes_namespace.bamboo.metadata[0].name
  repository = local.helm_chart_repository
  chart      = "bamboo-agent"
  version    = local.helm_chart_version

  depends_on = [helm_release.bamboo]

  values = [
    yamlencode({
      replicaCount = var.number_of_agents
      agent = {
        securityToken = {
          secretName = kubernetes_secret.security_token_secret.metadata[0].name
        }
        server = "${helm_release.bamboo.metadata[0].name}.${kubernetes_namespace.bamboo.metadata[0].name}.svc.cluster.local"
        resources = {
          container = {
            requests = {
              cpu    = "0.25"
              memory = "256m"
            }
          }
        }
      }
    }),
  ]
}