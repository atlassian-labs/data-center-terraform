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