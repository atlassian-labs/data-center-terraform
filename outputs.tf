output "vpc" {
  description = "VPC network information"

  value = {
    id                       = module.bamboo.vpc_id
    public_subnet_cidr       = module.bamboo.public_subnets_cidr_blocks
    vpc_public_subnets       = module.bamboo.public_subnets
    vpc_private_subnets_cidr = module.bamboo.private_subnets_cidr_blocks
    vpc_private_subnets      = module.bamboo.private_subnets
  }
}

output "efs" {
  description = "EFS shared storage"

  value = {
    efs = module.base-infrastructure.efs.efs_id
  }
}

output "ingress" {
  description = "Ingress controller deployed to access the products from outside of the cluster"

  value = {
    load_balancer_hostname = module.base-infrastructure.eks.ingress.lb_hostname
    certificate            = module.base-infrastructure.eks.ingress.certificate_arn
  }
}

output "product_urls" {
  description = "URLs to access the deployed Atlassian products"

  value = {
    bamboo = module.bamboo.product_domain_name
  }
}