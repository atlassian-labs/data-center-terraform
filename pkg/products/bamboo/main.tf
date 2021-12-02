# Create the infrastructure for Bamboo Data Center.

resource "aws_route53_record" "bamboo" {
  zone_id = var.eks.ingress.r53_zone
  name    = local.product_domain_name
  type    = "A"

  alias {
    evaluate_target_health = false
    name                   = var.eks.ingress.lb_hostname
    zone_id                = var.eks.ingress.lb_zone_id
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
    storage_class_name = "efs-cs"
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
    volume_name        = "atlassian-dc-bamboo-share-home-pv"
    storage_class_name = "efs-cs"
  }
}

module "database" {
  source = "../../modules/AWS/rds"

  db_tags           = merge(var.resource_tags, local.required_tags)
  product           = local.product_name
  rds_instance_id   = local.rds_instance_name
  allocated_storage = var.db_allocated_storage
  eks               = var.eks
  instance_class    = var.db_instance_class
  iops              = var.db_iops
  vpc               = var.vpc
}
