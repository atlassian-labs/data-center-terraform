# Create the infrastructure for Bamboo Data Center.
resource "aws_route53_record" "bamboo" {
  count = local.use_domain ? 1 : 0

  zone_id = var.ingress[0].ingress.r53_zone
  name    = local.product_domain_name
  type    = "A"

  alias {
    evaluate_target_health = false
    name                   = var.ingress[0].ingress.lb_hostname
    zone_id                = var.ingress[0].ingress.lb_zone_id
  }
}

resource "kubernetes_namespace" "bamboo" {
  metadata {
    name = local.product_name
  }
}

resource "kubernetes_persistent_volume" "atlassian-dc-bamboo-share-home-pv" {
  metadata {
    name = "atlassian-dc-bamboo-share-home-pv"
  }
  spec {
    capacity = {
      storage = var.share_home_size
    }
    volume_mode        = "Filesystem"
    access_modes       = ["ReadWriteMany"]
    storage_class_name = local.storage_class_name
    mount_options      = ["rw", "lookupcache=pos", "noatime", "intr", "_netdev"]
    persistent_volume_source {
      csi {
        driver        = "efs.csi.aws.com"
        volume_handle = var.efs.efs_id
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "atlassian-dc-bamboo-share-home-pvc" {
  metadata {
    name      = "atlassian-dc-bamboo-share-home-pvc"
    namespace = local.product_name
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = var.share_home_size
      }
    }
    volume_name        = kubernetes_persistent_volume.atlassian-dc-bamboo-share-home-pv.metadata[0].name
    storage_class_name = local.storage_class_name
  }
}

module "database" {
  source = "../../AWS/rds"

  product           = local.product_name
  rds_instance_id   = local.rds_instance_name
  allocated_storage = var.db_allocated_storage
  eks               = var.eks
  instance_class    = var.db_instance_class
  iops              = var.db_iops
  vpc               = var.vpc
}
