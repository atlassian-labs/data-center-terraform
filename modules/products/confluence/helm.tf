################################################################################
# Confluence DC helm installation
################################################################################
resource "helm_release" "confluence" {
  depends_on = [kubernetes_job.pre_install]
  name       = local.product_name
  namespace  = var.namespace
  repository = local.helm_chart_repository
  chart      = local.confluence_helm_chart_name
  version    = local.confluence_helm_chart_version
  timeout    = 10 * 60 # autoscaler potentially needs to scale up the cluster

  values = [
    yamlencode({
      replicaCount = var.replica_count,
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
        additionalEnvironmentVariables = [
          {
            name  = "ATL_SETUP_STEP",
            value = "complete"
          },
          {
            name  = "ATL_SETUP_TYPE",
            value = "cluster"
          },
          {
            name  = "ATL_BUILD_NUMBER",
            value = "8703"
          },
          {
            name  = "ATL_SNAPSHOT_USED",
            value = "true"
          },
        ]
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
            resources = {
              requests = {
                storage = var.local_home_size
              }
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
    local.context_path_settings,
    local.license_settings,
    local.synchrony_settings_stanza,
    local.version_tag,
    local.db_restore_env_vars,
  ]
}

################################################################################
# Fetch Confluence service details
################################################################################
data "kubernetes_service" "confluence" {
  depends_on = [helm_release.confluence]
  metadata {
    name      = local.product_name
    namespace = var.namespace
  }
}

################################################################################
# Fetch Confluence Synchrony service details
################################################################################
data "kubernetes_service" "confluence_synchrony" {
  depends_on = [helm_release.confluence]
  metadata {
    name      = "${local.product_name}-synchrony"
    namespace = var.namespace
  }
}

resource "random_string" "random" {
  length  = 10
  special = false
  number  = true
}