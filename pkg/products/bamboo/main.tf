# Create the infrastructure for Bamboo Data Center.

# a test instance - should be removed later
//resource "aws_instance" "test-vpc" {
//  ami                    = "ami-221ea342" #id of desired AMI
//  instance_type          = "m3.medium"
//  subnet_id              = var.vpc.subnet_id
//  vpc_security_group_ids = var.vpc.vpc_security_group_ids # list
//  Env = "test"
//}

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

# Create pvc
resource "kubernetes_persistent_volume_claim" "atlassian-dc-shared-home-pvc" {
  metadata {
    # This name is defined in `pom.xml` in the data-center-helm-charts
    name      = "atlassian-dc-shared-home-pvc"
    namespace = local.product_name # TODO - replace with product namespace
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = var.share_home_size
      }
    }
    storage_class_name = "efs-sc"
  }
}