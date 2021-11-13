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

#output "rds_db_name" {
#  value = aws_db_instance.postgres.name
#}
