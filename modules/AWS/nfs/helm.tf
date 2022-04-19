
resource "helm_release" "nfs" {
  chart     = "modules/AWS/nfs/nfs-server"
  name      = local.nfs_name
  namespace = var.namespace

  values = [
    yamlencode({
      nameOverride = var.chart_name
      persistence = {
        volumeClaimName = kubernetes_persistent_volume_claim.shared_home.metadata.0.name
      }
      resources = {
        limits = {
          cpu    = var.limits_cpu
          memory = var.limits_memory
        }
        requests = {
          cpu    = var.requests_cpu
          memory = var.requests_memory
        }
      }
    })
  ]
}