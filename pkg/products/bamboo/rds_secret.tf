################################################################################
# Kubernetes secret to store db credential
################################################################################
resource "kubernetes_secret" "rds_secret" {
  metadata {
    name      = "${local.product_name}-db-cred"
    namespace = kubernetes_namespace.bamboo.metadata[0].name
  }

  data = {
    username = module.database.rds_master_username
    password = module.database.rds_master_password
  }
}