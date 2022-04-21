output "helm_release_nfs_service_ip" {
  value = data.kubernetes_service.nfs.spec[0].cluster_ip
}

output "nfs_pvc_claim_name" {
  value = kubernetes_persistent_volume_claim.shared-home-pvc.metadata[0].name
}