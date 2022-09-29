resource "kubernetes_persistent_volume" "product_shared_home_pv" {
  metadata {
    name = "${var.product}-shared-home-pv"
  }
  spec {
    capacity = {
      storage = var.shared_home_size
    }
    volume_mode        = "Filesystem"
    access_modes       = ["ReadWriteMany"]
    storage_class_name = local.storage_class
    mount_options      = ["rw", "lookupcache=pos", "noatime", "intr", "_netdev", "nfsvers=3", "rsize=32768", "wsize=32768"]
    persistent_volume_source {
      nfs {
        path   = "/srv/nfs"
        server = var.cluster_service_ipv4
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "product_shared_home_pvc" {
  metadata {
    name      = "${var.product}-shared-home-pvc"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = var.shared_home_size
      }
    }
    volume_name        = kubernetes_persistent_volume.product_shared_home_pv.metadata[0].name
    storage_class_name = local.storage_class
  }
}
