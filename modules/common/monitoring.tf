resource "kubernetes_namespace" "monitoring" {
  count = var.monitoring_enabled == true ? 1 : 0
  metadata {
    name = "kube-monitoring"
  }
}

resource "helm_release" "prometheus_monitoring_stack" {
  count      = var.monitoring_enabled == true ? 1 : 0
  depends_on = [module.eks, module.vpc]
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "56.6.2"
  timeout    = 600 # it takes a while to install this Helm chart
  namespace  = kubernetes_namespace.monitoring[count.index].metadata[0].name

  values = [
    var.monitoring_custom_values_file != "" ? "${file(var.monitoring_custom_values_file)}" : "",
    yamlencode({
      grafana = {
        service = {
          type                     = var.monitoring_grafana_expose_lb == true ? "LoadBalancer" : "ClusterIP",
          loadBalancerSourceRanges = var.whitelist_cidr
        },
        persistence = {
          enabled = true
          size    = var.prometheus_pvc_disk_size
        },
        sidecar = {
          dashboards = {
            enabled    = true,
            label      = "grafana_dashboard",
            labelValue = "dc_monitoring"
          }
        }
      },
      prometheus = {
        prometheusSpec = {
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                accessModes = ["ReadWriteOnce"],
                resources = {
                  requests = {
                    storage = var.grafana_pvc_disk_size
                  }
                }
              }
            }
          }
        }
      }
    })
  ]
}
