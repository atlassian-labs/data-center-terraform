provider "helm" {
  kubernetes {
    config_path = module.eks.kubeconfig_filename
  }
}