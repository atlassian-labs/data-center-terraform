output "product_domain_name" {
  value = local.use_domain ? "https://${local.product_domain_name}" : "http://${data.kubernetes_service.bitbucket.status[0].load_balancer[0].ingress[0].hostname}"
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