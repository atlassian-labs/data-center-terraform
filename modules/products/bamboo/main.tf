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

module "database" {
  source = "../../AWS/rds"

  product              = local.product_name
  major_engine_version = var.db_major_engine_version
  rds_instance_id      = local.rds_instance_name
  allocated_storage    = var.db_configuration["db_allocated_storage"]
  eks                  = var.eks
  instance_class       = var.db_configuration["db_instance_class"]
  iops                 = var.db_configuration["db_iops"]
  vpc                  = var.vpc
}
