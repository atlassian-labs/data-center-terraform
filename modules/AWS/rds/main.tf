################################################################################
# AWS RDS Instance
################################################################################
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = "${var.product}_rds_sg"
  description = "Database security group"
  vpc_id      = var.vpc.vpc_id

  # ingress
  ingress_with_source_security_group_id = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL access from within EKS cluster"
      source_security_group_id = var.eks.cluster_security_group
    },
  ]
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = var.rds_instance_id

  create_db_option_group    = false
  create_db_parameter_group = false

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = local.engine_version
  family               = local.family             # DB parameter group
  major_engine_version = var.major_engine_version # DB option group
  instance_class       = var.instance_class

  allocated_storage = var.allocated_storage
  iops              = var.iops

  name     = local.rds_instance_name
  username = local.db_master_username
  password = local.db_master_password
  port     = 5432

  subnet_ids             = var.vpc.private_subnets
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Snapshot settings
  snapshot_identifier         = var.snapshot_identifier
  allow_major_version_upgrade = var.snapshot_identifier != null

  backup_retention_period = 0

  skip_final_snapshot = true
  apply_immediately   = true
}

resource "random_password" "password" {
  length           = 12
  special          = true
  override_special = "!#$%^&*(){}?<>,."
}