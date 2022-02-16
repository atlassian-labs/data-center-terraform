resource "helm_release" "nfs-for-bitbucket" {
  chart = "./nfs-chart"
  name  = "nfs"
  namespace  = var.namespace
}

data "kubernetes_service" "nfs" {
  depends_on = [helm_release.nfs-for-bitbucket]
  metadata {
    name      = "nfs-nfs-chart"
    namespace = var.namespace
  }
}