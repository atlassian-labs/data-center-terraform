output "vpc_id" {
  value       = var.vpc.vpc_id
  description = "VPC Id"
}
output "private_subnets" {
  value       = var.vpc.private_subnets
  description = "VPC private subnets"
}

output "private_subnets_cidr_blocks" {
  value       = var.vpc.private_subnets_cidr_blocks
  description = "VPC private subnet CIDR blocks"
}


output "public_subnets" {
  value       = var.vpc.public_subnets
  description = "VPC public subnets"
}

output "public_subnets_cidr_blocks" {
  value       = var.vpc.public_subnets_cidr_blocks
  description = "VPC public subnet CIDR blocks"
}

output "product_domain_name" {
  value = local.product_domain_name
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