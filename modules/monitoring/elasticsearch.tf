resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "7.16.3"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  values = [
    yamlencode({
      replicas           = 1
      minimumMasterNodes = 1
      antiAffinity       = "soft"
      resources = {
        requests = {
          cpu    = "2"
          memory = "512M"
        }
        limits = {
          cpu    = "3"
          memory = "1024M"
        }
      }

    })
  ]
}

resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  version    = "7.16.3"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  #  values     = [
  #    yamlencode({
  #      lifecycle = {
  #        postStart = {
  #          exec = {
  #            command = [
  #              "bash",
  #              "-c",
  #              local.kibana_import
  #            ]
  #          }
  #        }
  #      }
  #    }
  #    )
  #  ]
}

