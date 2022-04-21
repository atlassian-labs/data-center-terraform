resource "aws_ebs_volume" "shared_home" {
  availability_zone = var.availability_zone

  snapshot_id = var.shared_home_snapshot_id != null ? var.shared_home_snapshot_id : null
  size        = tonumber(regex("\\d+", var.capacity))
  type        = local.storage_class

  tags = {
    Name = "${var.product}-nfs-shared-home"
  }
}

resource "kubernetes_persistent_volume" "shared_home" {
  metadata {
    name = "${local.nfs_name}-pv"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    capacity = {
      storage = var.capacity
    }
    storage_class_name = local.storage_class
    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = aws_ebs_volume.shared_home.id
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "shared_home" {
  metadata {
    name      = "${local.nfs_name}-pvc"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.capacity
      }
    }
    storage_class_name = local.storage_class
    volume_name        = kubernetes_persistent_volume.shared_home.metadata.0.name
  }
}

data "kubernetes_service" "nfs" {
  depends_on = [helm_release.nfs]
  metadata {
    name      = format("%s-%s", helm_release.nfs.name, var.chart_name)
    namespace = var.namespace
  }
}

resource "kubernetes_persistent_volume" "shared-home-pv" {
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
        server = data.kubernetes_service.nfs.spec[0].cluster_ip
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "shared-home-pvc" {
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
    volume_name        = kubernetes_persistent_volume.shared-home-pv.metadata[0].name
    storage_class_name = local.storage_class
  }
}
