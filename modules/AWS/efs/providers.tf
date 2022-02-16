  provider "helm" {
  kubernetes {
    host                   = var.eks.kubernetes_provider_config.host
    token                  = var.eks.kubernetes_provider_config.token
    cluster_ca_certificate = var.eks.kubernetes_provider_config.cluster_ca_certificate
  }
}