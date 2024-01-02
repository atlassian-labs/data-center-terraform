resource "kubernetes_job" "pre_install" {
  lifecycle {
    ignore_changes = all
  }
  count = var.db_snapshot_id != null ? 1 : 0
  metadata {
    name      = "bitbucket-pre-install"
    namespace = var.namespace
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "pre-install"
          image   = "ubuntu"
          command = ["/bin/bash", "-c", "apt update; apt install postgresql-client -y; PGPASSWORD=${var.rds.rds_master_password} psql postgresql://${var.rds.rds_endpoint}/${local.product_name} -U ${var.rds.rds_master_username} -c \"update app_property SET prop_value = '${local.bitbucket_ingress_url}' WHERE prop_key = 'instance.url'; update app_property set prop_value = '${var.bitbucket_configuration["license"]}' where prop_key = 'license';\""]
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 10
    completions   = 1
  }
  wait_for_completion = true
  timeouts {
    create = "3m"
    update = "3m"
  }
}
