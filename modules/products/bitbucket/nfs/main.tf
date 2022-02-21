resource "helm_release" "nfs" {
  chart     = "https://raw.githubusercontent.com/atlassian/data-center-helm-charts/main/docs/docs/examples/storage/nfs/nfs-server-example-0.1.0.tgz"
  name      = "bitbucket-nfs"
  namespace = var.namespace

  values = [
    yamlencode({
      nameOverride = var.chart_name
      persistence = {
        size = var.capacity
      }
      resources = {
        limits = {
          cpu = var.limits_cpu
          memory = var.limits_memory
        }
        requests = {
          cpu = var.requests_cpu
          memory = var.requests_memory
        }
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
