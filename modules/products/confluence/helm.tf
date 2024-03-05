################################################################################
# Confluence DC helm installation
################################################################################
resource "helm_release" "confluence" {
  depends_on = [
    kubernetes_job.pre_install,
    kubernetes_persistent_volume_claim.local_home,
    time_sleep.wait_confluence_termination
  ]
  name       = local.product_name
  namespace  = var.namespace
  repository = local.helm_chart_repository
  chart      = local.confluence_helm_chart_name
  version    = local.confluence_helm_chart_version
  timeout    = var.installation_timeout * 60

  values = [
    var.confluence_configuration["custom_values_file"] != "" ? "${file(var.confluence_configuration["custom_values_file"])}" : "",
    yamlencode({
      replicaCount = var.replica_count,
      confluence = {
        shutdown = {
          terminationGracePeriodSeconds = var.termination_grace_period
        }
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
        additionalJvmArgs = concat(local.dcapt_analytics_property, local.irsa_properties)
      }
      synchrony = {
        resources = {
          jvm = {
            maxHeap    = local.synchrony_resources.maxHeap
            minHeap    = local.synchrony_resources.minHeap
            stack_size = local.synchrony_resources.stackSize
          }
          container = {
            requests = {
              cpu    = local.synchrony_resources.cpu
              memory = local.synchrony_resources.mem
            }
          }
        }
      }
      database = {
        type = "postgresql"
        url  = var.rds.rds_jdbc_connection
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
                storage = var.local_home_snapshot_id != null ? "${data.aws_ebs_snapshot.local_home_snapshot[0].volume_size}Gi" : var.local_home_size
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
              claimName = var.shared_home_pvc_name
            }
          }
        }
      }
      atlassianAnalyticsAndSupport = {
        analytics = {
          enabled = false
        }
      }
    }),
    local.ingress_settings,
    local.context_path_settings,
    local.license_settings,
    local.synchrony_settings_stanza,
    local.version_tag,
    local.db_restore_env_vars,
    local.service_account_annotations,
  ]
}

# Helm chart destruction will return immediately, we need to wait until the pods are fully evicted
# https://github.com/hashicorp/terraform-provider-helm/issues/593
resource "time_sleep" "wait_confluence_termination" {
  destroy_duration = "${var.termination_grace_period}s"
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
