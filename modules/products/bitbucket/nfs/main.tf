resource "helm_release" "nfs" {
  chart     = "./modules/products/bitbucket/nfs/nfs-chart"
  name      = format("%s-nfs", var.product)
  namespace = var.namespace

  values = [
    yamlencode({
      nameOverride = var.chart_name_override
      persistence = {
        size = var.capacity
      }
    })
  ]
}

data "kubernetes_service" "nfs" {
  depends_on = [helm_release.nfs]
  metadata {
    name      = format("%s-%s", helm_release.nfs.name, var.chart_name_override)
    namespace = var.namespace
  }
}
