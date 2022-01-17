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

output "rds_endpoint" {
  value = module.db.db_instance_endpoint
}

output "rds_jdbc_connection" {
  value = local.db_jdbc_connection
}