# Create the infrastructure for confluence Data Center.
resource "aws_route53_record" "confluence" {
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

# Install helm chart for confluence Data Center.

resource "helm_release" "confluence" {
  name       = local.product_name
  namespace  = var.namespace
  repository = local.helm_chart_repository
  chart      = local.confluence_helm_chart_name
  version    = local.confluence_helm_chart_version
  timeout    = 40 * 60 # dataset import can take a long time

  values = [
    yamlencode({
      confluence = {
        resources = {
          jvm = {
            maxHeap = local.confluence_software_resources.maxHeap
            minHeap = local.confluence_software_resources.minHeap
          }
          container = {
            requests = {
              cpu    = local.confluence_software_resources.cpu
              memory = local.confluence_software_resources.mem
            }
          }
        }
      }
      database = {
        type = "postgresql"
        url  = module.database.rds_jdbc_connection
        credentials = {
          secretName = kubernetes_secret.rds_secret.metadata[0].name
        }
      }
      volumes = {
        localHome = {
          persistentVolumeClaim = {
            create = true
          }
        }
        sharedHome = {
          customVolume = {
            persistentVolumeClaim = {
              claimName = var.pvc_claim_name
            }
          }
          subPath = local.product_name
        }
      }
    }),
    local.ingress_settings,
    local.license_settings,
  ]
}

data "kubernetes_service" "confluence" {
  depends_on = [helm_release.confluence]
  metadata {
    name      = local.product_name
    namespace = var.namespace
  }
}

