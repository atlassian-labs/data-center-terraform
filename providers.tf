provider "aws" {
  region = var.region

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