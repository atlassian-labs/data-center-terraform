output "nfs_claim_name" {
  value = kubernetes_persistent_volume_claim.shared-home-pvc.metadata[0].name
}