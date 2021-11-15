################################################################################
# AWS RDS Instance
################################################################################
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = "${var.product}_rds_sg"
  description = "Postgres security group"
  vpc_id      = var.vpc_id

  # ingress
  ingress_with_source_security_group_id = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL access from within EKS cluster"
      source_security_group_id = var.source_sg
    },
  ]

  tags = var.db_tags
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = var.rds_instance_id

  create_db_option_group    = false
  create_db_parameter_group = false

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "13.3"
  family               = "postgres13" # DB parameter group
  major_engine_version = "13"         # DB option group
  instance_class       = "db.t3.micro"

  allocated_storage = 1000
  iops              = 1000

  name                   = var.product
  username               = local.db_master_usr
  create_random_password = true
  random_password_length = 12
  port                   = 5432

  subnet_ids             = var.subnets
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 0

  skip_final_snapshot = true
  tags                = var.db_tags
}

################################################################################
# Kubernetes secret to store db credential
################################################################################
provider "kubernetes" {
  host                   = var.eks.kubernetes_provider_config.host
  token                  = var.eks.kubernetes_provider_config.token
  cluster_ca_certificate = var.eks.kubernetes_provider_config.cluster_ca_certificate
}

resource "kubernetes_secret" "rds_secret" {
  metadata {
    name = "${module.db.db_instance_id}-db-cred"
  }

  data = {
    username = local.db_master_usr
    password = module.db.db_instance_password
  }
}