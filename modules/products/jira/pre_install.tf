resource "kubernetes_job" "pre_install" {
  lifecycle {
    ignore_changes = all
  }
  count = var.db_snapshot_id != null ? 1 : 0
  metadata {
    name      = "jira-pre-install"
    namespace = var.namespace
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "pre-install"
          image   = "ubuntu"
          command = ["/bin/bash", "-c", "apt update; apt install postgresql-client -y; PGPASSWORD=${var.rds.rds_master_password} psql postgresql://${var.rds.rds_endpoint}/${local.product_name} -U ${var.rds.rds_master_username} -Atc \"update propertystring set propertyvalue = '${local.jira_ingress_url}' from propertyentry PE where PE.id=propertystring.id and PE.property_key = 'jira.baseurl'; update productlicense set license = '${var.jira_configuration["license"]}' from (select id from productlicense) as subquery where productlicense.id = subquery.id; \""]
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
