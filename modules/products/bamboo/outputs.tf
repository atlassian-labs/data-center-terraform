output "product_domain_name" {
  value = local.domain_supplied ? "https://${local.product_domain_name}" : "http://${var.ingress.outputs.lb_hostname}/${local.product_name}"
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
