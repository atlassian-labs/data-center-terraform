resource "kubernetes_job" "pre_install" {
  count      = var.db_snapshot_identifier != null ? 1 : 0
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
          command = ["/bin/bash", "-c", "apt update; apt install postgresql-client -y; BASE_URL_TO_REPLACE=$(PGPASSWORD=${var.db_master_password} psql postgresql://${module.database.rds_endpoint}/${local.product_name} -U ${var.db_master_username} -Atc \"select BANDANAVALUE from BANDANA where BANDANACONTEXT = '_GLOBAL' and BANDANAKEY = 'atlassian.confluence.settings';\" | grep -i '<baseurl>'); PGPASSWORD=${var.db_master_password} psql postgresql://${module.database.rds_endpoint}/${local.product_name} -U ${var.db_master_username} -c \"update BANDANA set BANDANAVALUE = replace(BANDANAVALUE, '$${BASE_URL_TO_REPLACE}', '<baseUrl>${local.confluence_ingress_url}</baseUrl>') where BANDANACONTEXT = '_GLOBAL' and BANDANAKEY = 'atlassian.confluence.settings';\" "]
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
