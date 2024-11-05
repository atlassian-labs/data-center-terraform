data "aws_ebs_snapshot" "local_home_snapshot" {
  count        = var.local_home_snapshot_id != null ? var.replica_count : 0
  snapshot_ids = [var.local_home_snapshot_id]
  most_recent  = true
}

resource "aws_ebs_volume" "local_home" {
  count             = var.local_home_snapshot_id != null ? var.replica_count : 0
  availability_zone = var.eks.availability_zone
  snapshot_id       = var.local_home_snapshot_id
  size              = data.aws_ebs_snapshot.local_home_snapshot[count.index].volume_size
  type              = "gp2"
  tags = {
    Name = "local-home-confluence-${count.index}"
  }
}

resource "kubernetes_persistent_volume" "local_home" {
  count = var.local_home_snapshot_id != null ? var.replica_count : 0
  metadata {
    name = "local-home-confluence-${count.index}"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    capacity = {
      storage = var.local_home_size
    }
    storage_class_name = local.storage_class
    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = aws_ebs_volume.local_home[count.index].id
      }
    }
    claim_ref {
      name      = "local-home-confluence-${count.index}"
      namespace = var.namespace
    }
  }
}

resource "kubernetes_persistent_volume_claim" "local_home" {
  count = var.local_home_snapshot_id != null ? var.replica_count : 0
  metadata {
    name      = "local-home-confluence-${count.index}"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.local_home_size
      }
    }
    storage_class_name = local.storage_class
    volume_name        = kubernetes_persistent_volume.local_home[count.index].metadata.0.name
  }
}
