output "helm_release_nfs_service_ip" {
  value = data.kubernetes_service.nfs.spec[0].cluster_ip
}

output "nfs_claim_name" {
  value = kubernetes_persistent_volume_claim.product_shared_home_pvc.metadata[0].name
}