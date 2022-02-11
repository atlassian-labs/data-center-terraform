output "vpc" {
  description = "VPC network information"

  value = {
    id                   = module.base-infrastructure.vpc.vpc_id
    public_subnets_cidr  = module.base-infrastructure.vpc.public_subnets_cidr_blocks
    private_subnets_cidr = module.base-infrastructure.vpc.private_subnets_cidr_blocks
  }
}

output "eks" {
  description = "EKS cluster information"

  value = {
    cluster_name     = module.base-infrastructure.eks.cluster_name
    cluster_id       = module.base-infrastructure.eks.cluster_id
    cluster_asg_name = module.base-infrastructure.eks.cluster_asg_name
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

output "bamboo_database" {
  description = "Bamboo Database information"

  value = local.install_bamboo && length(module.bamboo) == 1 ? {
    rds_instance_id        = module.bamboo[0].rds_instance_id
    db_name                = module.bamboo[0].db_name
    kubernetes_secret_name = module.bamboo[0].kubernetes_rds_secret_name
    jdbc_connection        = module.bamboo[0].rds_jdbc_connection
  } : null
}

output "jira_database" {
  description = "Jira Database information"

  value = local.install_jira && length(module.jira) == 1 ? {
    rds_instance_id        = module.jira[0].rds_instance_id
    db_name                = module.jira[0].db_name
    kubernetes_secret_name = module.jira[0].kubernetes_rds_secret_name
    jdbc_connection        = module.jira[0].rds_jdbc_connection
  } : null
}

output "product_urls" {
  description = "URLs to access the deployed Atlassian products"

  value = {
    bamboo = local.install_bamboo && length(module.bamboo) == 1 ? module.bamboo[0].product_domain_name : null
    jira   = local.install_jira && length(module.jira) == 1 ? module.jira[0].product_domain_name : null
  }
}