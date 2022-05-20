# Install helm chart for Bamboo Data Center.

resource "helm_release" "bamboo" {
  depends_on = [kubernetes_job.import_dataset]
  name       = local.product_name
  namespace  = var.namespace
  repository = local.helm_chart_repository
  chart      = local.bamboo_helm_chart_name
  version    = local.bamboo_helm_chart_version
  timeout    = var.installation_timeout * 60

  values = [
    yamlencode({
      bamboo = {
        resources = {
          jvm = {
            maxHeap = local.bamboo_software_resources.maxHeap
            minHeap = local.bamboo_software_resources.minHeap
          }
          container = {
            requests = {
              cpu    = local.bamboo_software_resources.cpu
              memory = local.bamboo_software_resources.mem
            }
          }
        }
        additionalJvmArgs = concat(local.dcapt_analytics_property)
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
    local.additional_environment_settings,
    local.ingress_settings,
    local.context_path_settings,
    local.license_settings,
    local.admin_settings,
    local.unattended_setup_setting,
    local.security_token_setting,
    local.dataset_settings,
    local.version_tag,
  ]
}

data "kubernetes_service" "bamboo" {
  depends_on = [helm_release.bamboo]
  metadata {
    name      = local.product_name
    namespace = var.namespace
  }
}

resource "helm_release" "bamboo_agent" {
  name       = local.agent_name
  namespace  = var.namespace
  repository = local.helm_chart_repository
  chart      = local.agent_helm_chart_name
  version    = local.agent_helm_chart_version

  depends_on = [helm_release.bamboo]

  values = [
    yamlencode({
      replicaCount = local.number_of_agents
      agent = {
        securityToken = {
          secretName = kubernetes_secret.security_token_secret.metadata[0].name
        }
        server = local.domain_supplied ? "${helm_release.bamboo.metadata[0].name}.${var.namespace}.svc.cluster.local" : "${helm_release.bamboo.metadata[0].name}.${var.namespace}.svc.cluster.local/bamboo"
        resources = {
          container = {
            requests = {
              cpu    = local.bamboo_agent_resources.cpu
              memory = local.bamboo_agent_resources.mem
            }
          }
        }
      }
    }),
    local.agent_version_tag,
  ]
}
