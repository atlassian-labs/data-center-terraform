resource "random_password" "confluence_secure_password" {
  length           = 25
  special          = true
  override_special = "!_-"
}

resource "local_file" "admin_passwd" {
  filename = "${path.root}/${local.product_name}_password.txt"
  content  = random_password.confluence_secure_password.result
}

resource "kubernetes_job" "post_install" {
  lifecycle {
    ignore_changes = all
  }
  count      = var.db_snapshot_id != null ? 1 : 0
  depends_on = [helm_release.confluence]
  metadata {
    name      = "confluence-change-passwd"
    namespace = var.namespace
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "change-password"
          image   = "appropriate/curl"
          command = ["/bin/sh", "-c"]
          args    = [local.cmd_change_password]
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 3
    completions   = 1
  }
  wait_for_completion = true
  timeouts {
    create = "2m"
    update = "2m"
  }
}
