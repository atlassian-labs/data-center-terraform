# Create the infrastructure for confluence Data Center.
resource "aws_route53_record" "confluence" {
  count = local.domain_supplied ? 1 : 0

  zone_id = var.ingress.outputs.r53_zone
  name    = local.product_domain_name
  type    = "A"

  alias {
    evaluate_target_health = false
    name                   = var.ingress.outputs.lb_hostname
    zone_id                = var.ingress.outputs.lb_zone_id
  }
}

module "database" {
  source = "../../AWS/rds"

  product                 = local.product_name
  rds_instance_identifier = local.rds_instance_name
  major_engine_version    = var.db_major_engine_version
  allocated_storage       = var.db_configuration["db_allocated_storage"]
  eks                     = var.eks
  instance_class          = var.db_configuration["db_instance_class"]
  iops                    = var.db_configuration["db_iops"]
  vpc                     = var.vpc
  snapshot_identifier     = var.db_snapshot_identifier
  db_master_username      = var.db_master_username
  db_master_password      = var.db_master_password
}

module "nfs" {
  source = "../../AWS/nfs"

  namespace               = var.namespace
  product                 = local.product_name
  requests_cpu            = var.nfs_requests_cpu
  requests_memory         = var.nfs_requests_memory
  limits_cpu              = var.nfs_limits_cpu
  limits_memory           = var.nfs_limits_memory
  capacity                = var.shared_home_size
  availability_zone       = var.eks.availability_zone
  shared_home_snapshot_id = var.shared_home_snapshot_id
}

resource "kubernetes_persistent_volume" "shared-home-pv" {
  metadata {
    name = "${local.product_name}-shared-home-pv"
  }
  spec {
    capacity = {
      storage = var.shared_home_size
    }
    volume_mode        = "Filesystem"
    access_modes       = ["ReadWriteMany"]
    storage_class_name = local.storage_class_name
    mount_options      = ["rw", "lookupcache=pos", "noatime", "intr", "_netdev", "nfsvers=3", "rsize=32768", "wsize=32768"]
    persistent_volume_source {
      nfs {
        path        = "/srv/nfs"
        server = module.nfs.helm_release_nfs_service_ip
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "shared-home-pvc" {
  metadata {
    name      = "${local.product_name}-shared-home-pvc"
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
    storage_class_name = local.storage_class_name
  }
}