resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "6.21.2"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
}

# Prometheus

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "15.1.1"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name


  #  values = [
  #    yamlencode({
  #      extraScrapeConfigs = [
  #        {
  #          job_name       = "jira-pods"
  #          scheme         = "http"
  #          metrics_path   = "/jira/plugins/servlet/prometheus/metrics"
  ##          static_configs = [
  ##            { targets = ["10.0.7.97:8080"] }
  ##          ]
  #        }
  #      ]
  #    })
  #  ]
}

resource "kubernetes_persistent_volume_claim" "atlassian-dc-monitoring-shared-home-pvc" {
  metadata {
    name      = "atlassian-dc-monitoring-shared-home-pvc"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    volume_name        = "atlassian-dc-share-home-pv"
    storage_class_name = "efs-cs"
  }
}

## Plugins
resource "kubernetes_job" "download_plugins" {
  timeouts {
    create = "15m"
    delete = "5m"
  }

  metadata {
    name      = "download-jmx-plugins"
    namespace = "monitoring"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name              = "import-dataset"
          image             = "alpine:latest"
          image_pull_policy = "Always"
          volume_mount {
            mount_path = "/shared-home"
            name       = "shared-home"
          }
          command = [
            "/bin/sh", "-c", <<-EOT
            apk update && apk add curl && \
            curl https://marketplace.atlassian.com/download/apps/1222502/version/1000130 --create-dirs -o /shared-home/jira/jira-jmx-exporter.jar && \
            curl https://marketplace.atlassian.com/download/apps/1223926/version/1000000 --create-dirs -o /shared-home/bitbucket/bitbucket-jmx-exporter.jar && \
            curl https://marketplace.atlassian.com/download/apps/1222502/version/1000130 --create-dirs -o /shared-home/confluence/confluence-jmx-exporter.jar && \
            curl https://marketplace.atlassian.com/download/apps/1222502/version/1000130 --create-dirs -o /shared-home/bamboo/bamboo-jmx-exporter.jar
            EOT
          ]
        }
        restart_policy = "Never"
        volume {
          name = "shared-home"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.atlassian-dc-monitoring-shared-home-pvc.metadata[0].name
          }
        }
      }
    }
    active_deadline_seconds = "600"
    backoff_limit           = 4
  }
  wait_for_completion = true
}



# Metrics server (autoscaler usage)

resource "helm_release" "metrics-server" {
  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  namespace        = kubernetes_namespace.monitoring.metadata[0].name
  create_namespace = true
}