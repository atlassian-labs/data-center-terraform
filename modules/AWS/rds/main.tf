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
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within EKS cluster (IPv4)"
      cidr_blocks = var.vpc.vpc_cidr_block
    }
  ]

  # IPv6 ingress
  ingress_with_ipv6_cidr_blocks = [
    {
      from_port        = 5432
      to_port          = 5432
      protocol         = "tcp"
      description      = "PostgreSQL access from within EKS cluster (IPv6)"
      ipv6_cidr_blocks = var.vpc.vpc_ipv6_cidr_block
    }
  ]
}

data "aws_db_snapshot" "atlassian_db_snapshot" {
  count                  = var.snapshot_identifier != null ? 1 : 0
  db_snapshot_identifier = var.snapshot_identifier
  most_recent            = true
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.1"

  identifier = var.rds_instance_identifier

  create_db_option_group    = false
  create_db_parameter_group = false

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = var.snapshot_identifier != null ? local.db_snapshot_engine_version : local.engine_version
  family               = local.family                                                                                        # DB parameter group
  major_engine_version = var.snapshot_identifier != null ? local.db_snapshot_major_engine_version : var.major_engine_version # DB option group
  instance_class       = var.instance_class

  allocated_storage = var.allocated_storage
  iops              = var.iops

  db_name                = var.db_name
  username               = local.db_master_username
  password               = var.db_master_password
  create_random_password = local.create_random_password
  port                   = 5432

  create_db_subnet_group = true
  subnet_ids             = var.vpc.private_subnets
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window         = "Mon:00:00-Mon:03:00"
  backup_window              = "03:00-06:00"
  auto_minor_version_upgrade = false
  storage_encrypted          = false

  # Snapshot settings
  snapshot_identifier         = var.snapshot_identifier
  allow_major_version_upgrade = var.snapshot_identifier != null

  backup_retention_period = 0

  skip_final_snapshot = true
  apply_immediately   = true
}
