output "vpc_id" {
  value       = module.bamboo.vpc_id
  description = "VPC Id"
}

output "vpc_public_subnets_cidr" {
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

output "ingress_load_balancer_hostname" {
  value = module.base-infrastructure.eks.ingress_load_balancer_hostname
}

output "bamboo_domain_name" {
  value = module.bamboo.product_domain_name
}