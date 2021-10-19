output "vpc_id" {
  value       = module.bamboo.vpc_id
  description = "VPC Id"
}

output "vpc_public_subnets_cidr_blocks" {
  value = module.bamboo.public_subnets_cidr_blocks
}

output "vpc_public_subnets" {
  value = module.bamboo.public_subnets
}

output "vpc_private_subnets_cidr" {
  value = module.bamboo.private_subnets_cidr_blocks
}

output "vpc_private_subnets" {
  value = module.bamboo.private_subnets
}