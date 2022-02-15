output "product_domain_name" {
  value = local.confluence_ingress_url
}

output "rds_instance_id" {
  value = module.database.rds_instance_id
}

output "rds_jdbc_connection" {
  value = module.database.rds_jdbc_connection
}

output "db_name" {
  value = module.database.rds_db_name
}

output "kubernetes_rds_secret_name" {
  value = kubernetes_secret.rds_secret.metadata[0].name
}

output "synchrony_url" {
  value = var.enable_synchrony ? local.synchrony_ingress_url : "Synchrony is disabled"
}