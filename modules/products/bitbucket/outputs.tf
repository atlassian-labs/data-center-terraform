output "product_domain_name" {
  value = local.bitbucket_ingress_url
}

output "rds_instance_id" {
  value = var.rds.rds_instance_id
}

output "rds_jdbc_connection" {
  value = var.rds.rds_jdbc_connection
}

output "db_name" {
  value = var.rds.rds_db_name
}

output "kubernetes_rds_secret_name" {
  value = kubernetes_secret.rds_secret.metadata[0].name
}

output "opensearch_endpoint" {
  value = local.opensearch_endpoint
}
