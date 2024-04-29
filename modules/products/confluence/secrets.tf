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

################################################################################
# Kubernetes secret to store OpenSearch initial password
################################################################################
resource "kubernetes_secret" "opensearch_secret" {
  count = var.opensearch_enabled ? 1 : 0

  metadata {
    name      = "opensearch-initial-password"
    namespace = var.namespace
  }

  data = {
    OPENSEARCH_INITIAL_ADMIN_PASSWORD = var.opensearch_initial_admin_password != null ? var.opensearch_initial_admin_password : random_password.opensearch.result
  }
}

resource "random_password" "opensearch" {
  length  = 16
  special = true
}