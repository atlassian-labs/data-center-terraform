# Install Helm chart for Bitbucket Data Center.

resource "helm_release" "bitbucket" {
  name       = local.product_name
  namespace  = var.namespace
  repository = local.helm_chart_repository
  chart      = local.product_name
  version    = local.bitbucket_helm_chart_version
  timeout    = 10 * 60 # autoscaler potentially needs to scale up the cluster

  values = [
    yamlencode({
      replicaCount = var.replica_count,
      bitbucket = {
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
      }
      database = {
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
        }
        sharedHome = {
          persistentVolume = {
            create = true
            nfs = {
              server = module.nfs.helm_release_nfs_service_ip
              path   = "/srv/nfs"
            }
          }
          persistentVolumeClaim = {
            create           = true
            storageClassName = ""
          }
          subPath = "${local.product_name}-${random_string.random.result}"
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

data "kubernetes_service" "bitbucket" {
  depends_on = [helm_release.bitbucket]
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