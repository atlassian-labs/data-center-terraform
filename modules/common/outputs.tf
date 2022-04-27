output "vpc" {
  value       = module.vpc
  description = "VPC Module"
}

output "vpc_name" {
  description = "Name of the VPC for the given environment"
  value       = local.vpc_name
}

output "cluster_name" {
  description = "Name of the cluster for the given environment"
  value       = local.cluster_name
}

output "eks" {
  value       = module.eks
  description = "EKS Module"
}

output "ingress" {
  value       = module.ingress
  description = "Ingress Module"
}

output "namespace" {
  value       = kubernetes_namespace.products.metadata[0].name
  description = "Namespace name for all products"
}
