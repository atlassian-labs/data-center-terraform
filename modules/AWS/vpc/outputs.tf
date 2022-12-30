output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC Id"
}

output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "VPC private subnets"
}

output "private_subnets_cidr_blocks" {
  value       = module.vpc.private_subnets_cidr_blocks
  description = "VPC private subnet CIDR blocks"
}


output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "VPC public subnets"
}

output "public_subnets_cidr_blocks" {
  value       = module.vpc.public_subnets_cidr_blocks
  description = "VPC public subnet CIDR blocks"
}

output "nat_public_ips" {
  value       = module.vpc.nat_public_ips
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
}
