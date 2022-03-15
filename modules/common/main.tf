module "vpc" {
  source = "../AWS/vpc"

  vpc_name = local.vpc_name
}

module "eks" {
  source = "../AWS/eks"

  region = var.region_name

  cluster_name = local.cluster_name

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  instance_types   = var.instance_types
  desired_capacity = var.desired_capacity
}

module "efs" {
  source = "../AWS/efs"
  count  = local.create_shared_home ? 1 : 0

  efs_name    = local.efs_name
  region_name = var.region_name
  vpc         = module.vpc
  eks         = module.eks

  // Having up to two replicas for the EFS controller should be enough
  csi_controller_replica_count = var.desired_capacity >= 2 ? 2 : 1
}

module "ingress" {
  source     = "../AWS/ingress"
  depends_on = [module.eks]

  # inputs
  ingress_domain = local.ingress_domain
  enable_ssh_tcp = var.enable_ssh_tcp
}

resource "kubernetes_namespace" "products" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_persistent_volume" "atlassian-dc-share-home-pv" {
  count = local.create_shared_home ? 1 : 0
  metadata {
    name = "atlassian-dc-share-home-pv"
  }
  spec {
    capacity = {
      storage = var.shared_home_size
    }
    volume_mode        = "Filesystem"
    access_modes       = ["ReadWriteMany"]
    storage_class_name = local.storage_class_name
    mount_options      = ["rw", "lookupcache=pos", "noatime", "intr", "_netdev"]
    persistent_volume_source {
      csi {
        driver        = "efs.csi.aws.com"
        volume_handle = module.efs[0].efs_id
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "atlassian-dc-share-home-pvc" {
  count = local.create_shared_home ? 1 : 0
  metadata {
    name      = "atlassian-dc-share-home-pvc"
    namespace = kubernetes_namespace.products.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = var.shared_home_size
      }
    }
    volume_name        = kubernetes_persistent_volume.atlassian-dc-share-home-pv[0].metadata[0].name
    storage_class_name = local.storage_class_name
  }
}
