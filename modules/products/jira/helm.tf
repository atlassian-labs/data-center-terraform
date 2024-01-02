# Install helm chart for Jira Data Center.

resource "helm_release" "jira" {
  depends_on = [
    kubernetes_job.pre_install,
    kubernetes_persistent_volume_claim.local_home,
    time_sleep.wait_jira_termination
  ]
  name       = local.product_name
  namespace  = var.namespace
  repository = local.helm_chart_repository
  chart      = local.jira_helm_chart_name
  version    = local.jira_helm_chart_version
  timeout    = var.installation_timeout * 60

  values = [
    var.jira_configuration["custom_values_file"] != "" ? "${file(var.jira_configuration["custom_values_file"])}" : "",
    yamlencode({
      replicaCount = var.replica_count,
      image = {
        repository = var.image_repository
      }
      jira = {
        shutdown = {
          terminationGracePeriodSeconds = var.termination_grace_period
        }
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
        additionalJvmArgs = concat(local.ignore_index_check, local.reuse_old_index_snapshot, local.dcapt_analytics_property)
      }
      database = {
        type   = "postgres72"
        url    = var.rds.rds_jdbc_connection
        driver = "org.postgresql.Driver"
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
                storage = var.local_home_snapshot_id != null ? "${data.aws_ebs_snapshot.local_home_snapshot[1].volume_size}Gi" : var.local_home_size
              }
            }
          }
          persistentVolumeClaimRetentionPolicy = {
            whenDeleted = var.local_home_retention_policy_when_deleted
            whenScaled  = var.local_home_retention_policy_when_scaled
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
    local.version_tag,
  ]
}

# Helm chart destruction will return immediately, we need to wait until the pods are fully evicted
# https://github.com/hashicorp/terraform-provider-helm/issues/593
resource "time_sleep" "wait_jira_termination" {
  destroy_duration = "${var.termination_grace_period}s"
  depends_on       = [module.nfs]
}

data "kubernetes_service" "jira" {
  depends_on = [helm_release.jira]
  metadata {
    name      = local.product_name
    namespace = var.namespace
  }
}
