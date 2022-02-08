module "vpc" {
  source = "../AWS/vpc"

  vpc_name = local.vpc_name
}

module "eks" {
  source = "../AWS/eks"

  cluster_name = local.cluster_name

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  instance_types   = var.instance_types
  desired_capacity = var.desired_capacity
}

module "efs" {
  source = "../AWS/efs"

  efs_name                     = local.efs_name
  region_name                  = var.region_name
  vpc                          = module.vpc
  eks                          = module.eks
  csi_controller_replica_count = var.desired_capacity
}

module "ingress" {
  count = local.ingress_domain != null ? 1 : 0

  source     = "../AWS/ingress"
  depends_on = [module.eks]

  # inputs
  ingress_domain = local.ingress_domain
}

resource "kubernetes_namespace" "products" {
  metadata {
    name = var.namespace
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
        volume_handle = module.efs.efs_id
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "atlassian-dc-bamboo-share-home-pvc" {
  metadata {
    name      = "atlassian-dc-bamboo-share-home-pvc"
    namespace = kubernetes_namespace.products.metadata[0].name
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
