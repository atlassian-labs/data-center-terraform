resource "aws_ebs_volume" "shared_home" {
  availability_zone = var.availability_zone

  snapshot_id = var.shared_home_snapshot_id != null ? var.shared_home_snapshot_id : null
  size        = tonumber(regex("\\d+", var.capacity))
  type        = "gp2"

  tags = {
    Name = "nfs-shared-home"
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
    storage_class_name = "gp2"
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
    storage_class_name = "gp2"
    volume_name        = kubernetes_persistent_volume.shared_home.metadata.0.name
  }
}


resource "helm_release" "nfs" {
  chart     = "modules/AWS/nfs/nfs-server"
  name      = local.nfs_name
  namespace = var.namespace

  values = [
    yamlencode({
      nameOverride = var.chart_name
      persistence = {
        volumeClaimName = kubernetes_persistent_volume_claim.shared_home.metadata.0.name
      }
      resources = {
        limits = {
          cpu    = var.limits_cpu
          memory = var.limits_memory
        }
        requests = {
          cpu    = var.requests_cpu
          memory = var.requests_memory
        }
      }
    })
  ]
}

data "kubernetes_service" "nfs" {
  depends_on = [helm_release.nfs]
  metadata {
    name      = format("%s-%s", helm_release.nfs.name, var.chart_name)
    namespace = var.namespace
  }
}
