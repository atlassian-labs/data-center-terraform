# Create the infrastructure for Jira Data Center.
resource "aws_route53_record" "jira" {
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

  namespace               = var.namespace
  product                 = local.product_name
  requests_cpu            = var.nfs_requests_cpu
  requests_memory         = var.nfs_requests_memory
  limits_cpu              = var.nfs_limits_cpu
  limits_memory           = var.nfs_limits_memory
  availability_zone       = var.eks.availability_zone
  shared_home_snapshot_id = var.shared_home_snapshot_id
  shared_home_size        = var.shared_home_size
  cluster_service_ipv4    = local.nfs_cluster_service_ipv4

}

module "database" {
  source = "../../AWS/rds"

  product                 = local.product_name
  rds_instance_identifier = local.rds_instance_id
  allocated_storage       = var.db_allocated_storage
  eks                     = var.eks
  instance_class          = var.db_instance_class
  iops                    = var.db_iops
  vpc                     = var.vpc
  major_engine_version    = var.db_major_engine_version
  snapshot_identifier     = var.db_snapshot_id
  db_master_username      = var.db_master_username
  db_master_password      = var.db_master_password
  db_name                 = var.db_name
}
