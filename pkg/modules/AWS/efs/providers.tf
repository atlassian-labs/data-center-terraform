provider "helm" {
  kubernetes {
    config_path = var.eks.kubeconfig_filename
  }
}