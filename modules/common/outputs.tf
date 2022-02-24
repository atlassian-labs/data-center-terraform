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
  value       = module.efs
  description = "EFS Module"
}

output "ingress" {
  value       = module.ingress
  description = "Ingress Module"
}

output "pvc_claim_name" {
  value       = kubernetes_persistent_volume_claim.atlassian-dc-share-home-pvc.metadata[0].name
  description = "Persistent volume claim name"
}

output "namespace" {
  value       = kubernetes_namespace.products.metadata[0].name
  description = "Namespace name for all products"
}
