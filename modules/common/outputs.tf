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
  sensitive   = true
}

output "ingress" {
  value       = var.use_gateway_api ? module.gateway[0] : module.ingress[0]
  description = "Ingress/Gateway Module (provides consistent outputs.* interface)"
}

output "use_gateway_api" {
  value       = var.use_gateway_api
  description = "Whether Gateway API is being used instead of NGINX Ingress"
}

output "namespace" {
  value       = kubernetes_namespace.products.metadata[0].name
  description = "Namespace name for all products"
}
