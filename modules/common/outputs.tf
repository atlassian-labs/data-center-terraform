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

output "efs" {
  value       = local.create_share_home && length(module.efs) == 1 ? module.efs : null
  description = "EFS Module"
}

output "ingress" {
  value       = module.ingress
  description = "Ingress Module"
}

output "pvc_claim_name" {
  value       = local.create_share_home ? kubernetes_persistent_volume_claim.atlassian-dc-share-home-pvc[0].metadata[0].name : null
  description = "Persistent volume claim name"
}

output "namespace" {
  value       = kubernetes_namespace.products.metadata[0].name
  description = "Namespace name for all products"
}
