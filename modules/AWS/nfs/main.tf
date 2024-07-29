resource "aws_ebs_volume" "shared_home" {
  availability_zone = var.availability_zone

  snapshot_id = var.shared_home_snapshot_id != null ? var.shared_home_snapshot_id : null
  size        = tonumber(regex("\\d+", var.shared_home_size))
  type        = "gp2"

  tags = {
    Name = "${var.product}-nfs-shared-home"
  }
}

resource "kubernetes_persistent_volume" "nfs_shared_home" {
  metadata {
    name = "${local.nfs_name}-pv"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    capacity = {
      storage = var.shared_home_size
    }
    storage_class_name = local.storage_class
    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = aws_ebs_volume.shared_home.id
      }
    }
    claim_ref {
      name      = "${local.nfs_name}-pvc"
      namespace = var.namespace
    }
  }
}

resource "kubernetes_persistent_volume_claim" "nfs_shared_home" {
  metadata {
    name      = "${local.nfs_name}-pvc"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.shared_home_size
      }
    }
    storage_class_name = local.storage_class
    volume_name        = kubernetes_persistent_volume.nfs_shared_home.metadata.0.name
  }
}

data "kubernetes_service" "nfs" {
  depends_on = [helm_release.nfs]
  metadata {
    name      = format("%s-%s", helm_release.nfs.name, var.chart_name)
    namespace = var.namespace
  }
}
