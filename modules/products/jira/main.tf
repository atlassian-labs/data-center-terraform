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

module "database" {
  source = "../../AWS/rds"

  product              = local.product_name
  rds_instance_id      = local.rds_instance_name
  allocated_storage    = var.db_allocated_storage
  eks                  = var.eks
  instance_class       = var.db_instance_class
  iops                 = var.db_iops
  vpc                  = var.vpc
  major_engine_version = var.db_major_engine_version
  snapshot_identifier  = var.db_snapshot_identifier
  db_master_username   = var.db_master_username
  db_master_password   = var.db_master_password
}
