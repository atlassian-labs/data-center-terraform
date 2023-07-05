# Install helm chart for Crowd Data Center.

resource "helm_release" "crowd" {
  depends_on = [
    module.database,
    time_sleep.wait_crowd_termination
  ]
  name       = local.product_name
  namespace  = var.namespace
  repository = local.helm_chart_repository
  chart      = local.crowd_helm_chart_name
  version    = local.crowd_helm_chart_version
  timeout    = var.installation_timeout * 60

  values = [
    var.crowd_configuration["custom_values_file"] != "" ? "${file(var.crowd_configuration["custom_values_file"])}" : "",
    yamlencode({
      replicaCount = var.replica_count,
      image = {
        repository = var.image_repository
      }
      crowd = {
        shutdown = {
          terminationGracePeriodSeconds = var.termination_grace_period
        }
        resources = {
          jvm = {
            maxHeap = local.crowd_software_resources.maxHeap
            minHeap = local.crowd_software_resources.minHeap
          }
          container = {
            requests = {
              cpu    = local.crowd_software_resources.cpu
              memory = local.crowd_software_resources.mem
            }
          }
        }
        additionalJvmArgs = concat(local.dcapt_analytics_property)
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
    local.version_tag,
  ]
}

# Helm chart destruction will return immediately, we need to wait until the pods are fully evicted
# https://github.com/hashicorp/terraform-provider-helm/issues/593
resource "time_sleep" "wait_crowd_termination" {
  destroy_duration = "${var.termination_grace_period}s"
  depends_on       = [module.nfs]
}

data "kubernetes_service" "crowd" {
  depends_on = [helm_release.crowd]
  metadata {
    name      = local.product_name
    namespace = var.namespace
  }
}
