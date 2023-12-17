# Create the infrastructure for Bamboo Data Center.
resource "aws_route53_record" "bamboo" {
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

module "nfs" {
  source = "../../AWS/nfs"

  namespace            = var.namespace
  product              = local.product_name
  requests_cpu         = var.nfs_requests_cpu
  requests_memory      = var.nfs_requests_memory
  limits_cpu           = var.nfs_limits_cpu
  limits_memory        = var.nfs_limits_memory
  availability_zone    = var.eks.availability_zone
  shared_home_size     = var.shared_home_size
  cluster_service_ipv4 = local.nfs_cluster_service_ipv4
}
