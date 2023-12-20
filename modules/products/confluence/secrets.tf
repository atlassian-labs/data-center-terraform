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

################################################################################
# Kubernetes secret to store license
################################################################################
resource "kubernetes_secret" "license_secret" {
  metadata {
    name      = "${local.product_name}-license"
    namespace = var.namespace
  }

  data = {
    license-key = var.confluence_configuration["license"]
  }
}
