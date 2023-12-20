################################################################################
# Kubernetes secret to store db credential
################################################################################
resource "kubernetes_secret" "rds_secret" {
  metadata {
    name      = "${local.product_name}-db-cred"
    namespace = var.namespace
  }

  data = {
    username = var.rds.rds_master_username
    password = var.rds.rds_master_password
  }
}
