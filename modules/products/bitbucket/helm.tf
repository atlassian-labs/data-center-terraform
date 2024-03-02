# Install Helm chart for Bitbucket Data Center.

resource "helm_release" "bitbucket" {
  depends_on = [
    kubernetes_job.pre_install,
    time_sleep.wait_bitbucket_termination
  ]
  name       = local.product_name
  namespace  = var.namespace
  repository = local.helm_chart_repository
  chart      = local.bitbucket_helm_chart_name
  version    = local.bitbucket_helm_chart_version
  timeout    = var.installation_timeout * 60

  values = [
    var.bitbucket_configuration["custom_values_file"] != "" ? "${file(var.bitbucket_configuration["custom_values_file"])}" : "",
    yamlencode({
      replicaCount = var.replica_count,
      bitbucket = {
        shutdown = {
          terminationGracePeriodSeconds = var.termination_grace_period
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
        elasticSearch = {
          baseUrl = local.elasticsearch_endpoint
        }
        additionalJvmArgs = concat(local.dcapt_analytics_property)
      }
      database = {
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
                storage = var.local_home_size
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
    local.admin_settings,
    local.version_tag,
    local.display_name,
  ]
}

# Helm chart destruction will return immediately, we need to wait until the pods are fully evicted
# https://github.com/hashicorp/terraform-provider-helm/issues/593
resource "time_sleep" "wait_bitbucket_termination" {
  destroy_duration = "${var.termination_grace_period}s"
}

data "kubernetes_service" "bitbucket" {
  depends_on = [helm_release.bitbucket]
  metadata {
    name      = local.product_name
    namespace = var.namespace
  }
}
