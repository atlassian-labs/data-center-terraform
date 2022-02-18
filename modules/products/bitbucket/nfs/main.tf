resource "helm_release" "nfs" {
  chart     = "https://github.com/atlassian/data-center-helm-charts/tree/main/docs/docs/examples/storage/nfs/nfs-server-example"
  name      = format("%s-nfs", var.product)
  namespace = var.namespace

  values = [
    yamlencode({
      nameOverride = var.chart_name
      persistence = {
        size = var.capacity
      }
    })
  ]
}

data "kubernetes_service" "nfs" {
  depends_on = [helm_release.nfs]
  metadata {
    name      = format("%s-%s", helm_release.nfs.name, var.chart_name)
    namespace = var.namespace
  }
}
