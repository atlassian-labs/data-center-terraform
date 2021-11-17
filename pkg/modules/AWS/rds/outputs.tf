output "rds_instance_id" {
  value = module.db.db_instance_id
}

output "rds_master_username" {
  value     = module.db.db_instance_username
  sensitive = true
}

output "rds_master_password" {
  value     = module.db.db_master_password
  sensitive = true
}

output "rds_db_name" {
  value = module.db.db_instance_name
}

output "kubernetes_rds_secret_name" {
  value = kubernetes_secret.rds_secret.metadata[0].name
}
