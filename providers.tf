provider "aws" {
  region = var.region
  // This will allow an AWS provider to add the resource tags to every AWS resources except ASG resources (See https://learn.hashicorp.com/tutorials/terraform/aws-default-tags?in=terraform/aws)
  default_tags {
    tags = var.resource_tags
  }
}

provider "kubernetes" {
  host                   = module.base-infrastructure.eks.kubernetes_provider_config.host
  token                  = module.base-infrastructure.eks.kubernetes_provider_config.token
  cluster_ca_certificate = module.base-infrastructure.eks.kubernetes_provider_config.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = module.base-infrastructure.eks.kubernetes_provider_config.host
    token                  = module.base-infrastructure.eks.kubernetes_provider_config.token
    cluster_ca_certificate = module.base-infrastructure.eks.kubernetes_provider_config.cluster_ca_certificate
  }
}