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
  timeout    = var.installation_timeout * 60

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
              claimName = module.nfs.nfs_claim_name
            }
          }
        }
      }
    }),
    local.ingress_settings,
    local.context_path_settings,
    local.license_settings,
    local.synchrony_settings_stanza,
    local.version_tag,
    local.db_restore_env_vars,
    local.extend_snapshot_validity,
    local.extend_reindex_thread_counts,
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