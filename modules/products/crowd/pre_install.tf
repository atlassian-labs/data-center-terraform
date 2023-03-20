resource "kubernetes_job" "pre_install" {
  lifecycle {
    ignore_changes = all
  }
  count      = var.db_snapshot_id != null ? 1 : 0
  depends_on = [module.database]
  metadata {
    name      = "crowd-pre-install"
    namespace = var.namespace
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "update-db"
          image   = "ubuntu"
          command = ["/bin/bash", "-c", "apt update; apt install postgresql-client -y; PGPASSWORD=${var.db_master_password} psql postgresql://${module.database.rds_endpoint}/${local.product_name} -U ${var.db_master_username} -c \"UPDATE cwd_property SET property_value = '${local.crowd_ingress_url}' WHERE property_name = 'base.url';\""]
        }
        container {
          name    = "update-cfg-xml"
          image   = "ubuntu"
          command = ["/bin/bash", "-c", "cd home; apt update; apt install xmlstarlet -y; xmlstarlet ed -L -u \"/application-configuration/properties/property[@name='license']\" -v ${var.crowd_configuration["license"]} crowd.cfg.xml; xmlstarlet ed -L -u \"/application-configuration/properties/property[@name='hibernate.connection.username']\" -v ${var.db_master_username} crowd.cfg.xml; xmlstarlet ed -L -u \"/application-configuration/properties/property[@name='hibernate.connection.password']\" -v ${var.db_master_password} crowd.cfg.xml; xmlstarlet ed -L -u \"/application-configuration/properties/property[@name='hibernate.connection.url']\" -v jdbc:postgresql://${module.database.rds_endpoint}/${local.product_name}?reWriteBatchedInserts=true crowd.cfg.xml;"]
          volume_mount {
            name       = "shared-home"
            mount_path = "/home"
          }
        }
        restart_policy = "Never"
        volume {
          name = "shared-home"
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
