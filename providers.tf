locals {
  cluster_name = format("atlas-%s-cluster", var.environment_name)
}

provider "aws" {
  region = var.region
  // This will allow an AWS provider to add the resource tags to every AWS resources except ASG resources (See https://learn.hashicorp.com/tutorials/terraform/aws-default-tags?in=terraform/aws)
  default_tags {
    tags = var.resource_tags
  }
}

provider "kubernetes" {
  host                   = module.base-infrastructure.eks.kubernetes_provider_config.host
  cluster_ca_certificate = module.base-infrastructure.eks.kubernetes_provider_config.cluster_ca_certificate
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.base-infrastructure.eks.kubernetes_provider_config.host
    cluster_ca_certificate = module.base-infrastructure.eks.kubernetes_provider_config.cluster_ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
      command     = "aws"
    }
  }
}