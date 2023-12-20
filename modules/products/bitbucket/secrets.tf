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
    license-key = var.bitbucket_configuration["license"]
  }
}

################################################################################
# Kubernetes secret to store system admin credentials
################################################################################
resource "kubernetes_secret" "admin_secret" {
  count = var.admin_configuration["admin_username"] != null ? 1 : 0
  metadata {
    name      = "${local.product_name}-admin"
    namespace = var.namespace
  }

  data = {
    username     = var.admin_configuration["admin_username"]
    password     = var.admin_configuration["admin_password"]
    displayName  = var.admin_configuration["admin_display_name"]
    emailAddress = var.admin_configuration["admin_email_address"]
  }
}
