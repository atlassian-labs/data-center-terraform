output "helm_release_nfs_service_ip" {
  value = data.kubernetes_service.nfs.spec[0].cluster_ip
}
