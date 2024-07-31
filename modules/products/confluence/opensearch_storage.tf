data "aws_ebs_snapshot" "opensearch_snapshot" {
  count = var.opensearch_enabled && var.opensearch_snapshot_id != null ? 1 : 0

  snapshot_ids = [var.opensearch_snapshot_id]
  most_recent  = true
}

resource "aws_ebs_volume" "opensearch" {
  count = var.opensearch_enabled && var.opensearch_snapshot_id != null ? 1 : 0

  availability_zone = var.eks.availability_zone
  snapshot_id       = var.opensearch_snapshot_id
  size              = data.aws_ebs_snapshot.opensearch_snapshot[0].volume_size
  type              = "gp2"
  tags = {
    Name = "confluence-opensearch"
  }
}

resource "kubernetes_persistent_volume" "opensearch" {
  count = var.opensearch_enabled && var.opensearch_snapshot_id != null ? 1 : 0

  metadata {
    name = "confluence-opensearch-pv"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    capacity = {
      storage = data.aws_ebs_snapshot.opensearch_snapshot[0].volume_size
    }
    storage_class_name = local.opensearch_storage_class
    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = aws_ebs_volume.opensearch[0].id
      }
    }
    claim_ref {
      name      = "opensearch-cluster-master-opensearch-cluster-master-0"
      namespace = var.namespace
    }
  }
}

resource "kubernetes_persistent_volume_claim" "opensearch" {
  count = var.opensearch_enabled && var.opensearch_snapshot_id != null ? 1 : 0

  metadata {
    name      = "opensearch-cluster-master-opensearch-cluster-master-0"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = data.aws_ebs_snapshot.opensearch_snapshot[0].volume_size
      }
    }
    storage_class_name = local.opensearch_storage_class
    volume_name        = kubernetes_persistent_volume.opensearch[0].metadata.0.name
  }
}
