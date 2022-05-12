resource "kubernetes_job" "pre_install" {
  count      = var.db_snapshot_id != null ? 1 : 0
  depends_on = [module.database]
  metadata {
    name      = "confluence-pre-install"
    namespace = var.namespace
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "pre-install"
          image   = "ubuntu"
          command = ["/bin/bash", "-c", "apt update; apt install postgresql-client -y; ${local.cmd_psql_update}; ${local.cmd_license_update}"]
          volume_mount {
            mount_path = "/shared-home"
            name       = "nfs-shared-home"
          }
        }
        restart_policy = "Never"
        volume {
          name = "nfs-shared-home"
          persistent_volume_claim {
            claim_name = module.nfs.nfs_claim_name
          }
        }
      }
    }
    backoff_limit = 10
    completions   = 1
  }
  wait_for_completion = true
  timeouts {
    create = "2m"
    update = "2m"
  }
}
