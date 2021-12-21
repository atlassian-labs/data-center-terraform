resource "kubernetes_job" "import_dataset" {
  count = var.dataset_url != null ? 1 : 0

  metadata {
    name      = "bamboo-import-dataset"
    namespace = kubernetes_namespace.bamboo.metadata[0].name
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
            "/bin/sh", "-c", "apk update && apk add wget && wget ${var.dataset_url} -O /shared-home/${local.dataset_filename}"
          ]
        }
        restart_policy = "Never"
        volume {
          name = "shared-home"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.atlassian-dc-bamboo-share-home-pvc.metadata[0].name
          }
        }
      }
    }
    active_deadline_seconds = "600"
    backoff_limit           = 4
  }
  wait_for_completion = true
}