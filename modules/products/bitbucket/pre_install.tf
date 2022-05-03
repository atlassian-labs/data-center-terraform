resource "kubernetes_job" "pre_install" {
  count      = var.db_snapshot_id != null ? 1 : 0
  depends_on = [module.database]
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
          command = ["/bin/bash", "-c", "apt update; apt install postgresql-client -y; PGPASSWORD=${var.db_master_password} psql postgresql://${module.database.rds_endpoint}/${local.product_name} -U ${var.db_master_username} -c \"update app_property SET prop_value = '${local.bitbucket_ingress_url}' WHERE prop_key = 'instance.url'; update app_property set prop_value = '${var.bitbucket_configuration["license"]}' where prop_key = 'license';\""]
        }
        restart_policy = "Never"
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
