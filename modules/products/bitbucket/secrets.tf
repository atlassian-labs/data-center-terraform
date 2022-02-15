################################################################################
# Kubernetes secret to store db credential
################################################################################
resource "kubernetes_secret" "rds_secret" {
  metadata {
    name      = "${local.product_name}-db-cred"
    namespace = var.namespace
  }

  data = {
    username = module.database.rds_master_username
    password = module.database.rds_master_password
  }
}

################################################################################
# Kubernetes secret to store license
################################################################################
resource "kubernetes_secret" "license_secret" {
  metadata {
    name      = "${local.product_name}-license"
    namespace = var.namespace
  }

  data = {
    license-key = var.bitbucket_configuration["license"]
  }
}