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

################################################################################
# Kubernetes secret to store license
################################################################################
resource "kubernetes_secret" "license_secret" {
  metadata {
    name      = "${local.product_name}-license"
    namespace = kubernetes_namespace.bamboo.metadata[0].name
  }

  data = {
    license = var.license
  }
}

################################################################################
# Kubernetes secret to store system admin credentials
################################################################################
resource "kubernetes_secret" "admin_secret" {
  metadata {
    name      = "${local.product_name}-admin"
    namespace = kubernetes_namespace.bamboo.metadata[0].name
  }

  data = {
    username     = var.admin_username
    password     = var.admin_password
    displayName  = var.admin_display_name
    emailAddress = var.admin_email_address
  }
}