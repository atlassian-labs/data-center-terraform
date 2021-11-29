output "vpc" {
  description = "VPC network information"

  value = {
    id                   = module.bamboo.vpc_id
    public_subnets       = module.bamboo.public_subnets
    public_subnets_cidr  = module.bamboo.public_subnets_cidr_blocks
    private_subnets      = module.bamboo.private_subnets
    private_subnets_cidr = module.bamboo.private_subnets_cidr_blocks
  }
}

output "efs" {
  description = "EFS shared storage"

  value = {
    efs = module.base-infrastructure.efs.efs_id
  }
}

output "ingress" {
  description = "Ingress controller deployed to access the products from outside of the cluster (ingress is provisioned only when the domain is configured)"

  value = var.domain != null ? {
    load_balancer_hostname = module.base-infrastructure.ingress[0].ingress.lb_hostname
    certificate            = module.base-infrastructure.ingress[0].ingress.certificate_arn
    } : {
    load_balancer_hostname = null
    certificate            = null
  }
}

output "product_urls" {
  description = "URLs to access the deployed Atlassian products"

  value = {
    bamboo = module.bamboo.product_domain_name
  }
}

output "database" {
  description = "Database information"

  value = {
    rds_instance_id        = module.bamboo.rds_instance_id
    db_name                = module.bamboo.db_name
    kubernetes_secret_name = module.bamboo.kubernetes_rds_secret_name
    jdbc_connection        = module.bamboo.rds_jdbc_connection
  }
}