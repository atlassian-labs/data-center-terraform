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
    efs = module.base-infrastructure.efs == null ? null : module.base-infrastructure.efs[0].efs_id
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

output "jira_database" {
  description = "Jira Database information"

  value = local.install_jira && length(module.jira) == 1 ? {
    rds_instance_id        = module.jira[0].rds_instance_id
    db_name                = module.jira[0].db_name
    kubernetes_secret_name = module.jira[0].kubernetes_rds_secret_name
    jdbc_connection        = module.jira[0].rds_jdbc_connection
  } : null
}

output "confluence_database" {
  description = "Confluence database information"

  value = local.install_confluence && length(module.confluence) == 1 ? {
    rds_instance_id        = module.confluence[0].rds_instance_id
    db_name                = module.confluence[0].db_name
    kubernetes_secret_name = module.confluence[0].kubernetes_rds_secret_name
    jdbc_connection        = module.confluence[0].rds_jdbc_connection
  } : null
}

output "bitbucket_database" {
  description = "Bitbucket database information"

  value = local.install_bitbucket && length(module.bitbucket) == 1 ? {
    rds_instance_id        = module.bitbucket[0].rds_instance_id
    db_name                = module.bitbucket[0].db_name
    kubernetes_secret_name = module.bitbucket[0].kubernetes_rds_secret_name
    jdbc_connection        = module.bitbucket[0].rds_jdbc_connection
  } : null
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

output "product_urls" {
  description = "URLs to access the deployed Atlassian products"

  value = {
    jira       = local.install_jira && length(module.jira) == 1 ? module.jira[0].product_domain_name : null
    bitbucket  = local.install_bitbucket && length(module.bitbucket) == 1 ? module.bitbucket[0].product_domain_name : null
    bamboo     = local.install_bamboo && length(module.bamboo) == 1 ? module.bamboo[0].product_domain_name : null
    confluence = local.install_confluence && length(module.confluence) == 1 ? module.confluence[0].product_domain_name : null
  }
}

output "synchrony_url" {
  description = "URL to access the Synchrony (collaborative editing)"
  value       = var.confluence_collaborative_editing_enabled && length(module.confluence) == 1 ? module.confluence[0].synchrony_url : null
}

output "elasticsearch_url" {
  description = "URL to access the Bitbucket elasticsearch"
  value       = local.install_bitbucket && length(module.bitbucket) == 1 ? module.bitbucket[0].elasticsearch_endpoint : null
}
