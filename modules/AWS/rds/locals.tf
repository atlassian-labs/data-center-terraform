locals {
  db_master_username     = var.db_master_username == null ? "postgres" : var.db_master_username
  create_random_password = var.db_master_password == null ? true : false
  db_jdbc_connection     = "jdbc:postgresql://${module.db.db_instance_endpoint}/${var.product}"

  # RDS major version is mapped to the latest minor version for more details.
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts.General.version13
  engine_version = lookup(
    {
      "12" = "12.22",
      "13" = "13.20",
      "14" = "14.17",
      "15" = "15.12",
      "16" = "16.8",
      "17" = "17.4",
  }, var.major_engine_version, "14.17")

  family = lookup(
    {
      "12" = "postgres12",
      "13" = "postgres13",
      "14" = "postgres14",
      "15" = "postgres15",
      "16" = "postgres16",
      "17" = "postgres17",
  }, var.major_engine_version, "postgres14")

  db_snapshot_engine_version       = var.snapshot_identifier != null ? data.aws_db_snapshot.atlassian_db_snapshot[0].engine_version : null
  db_snapshot_major_engine_version = var.snapshot_identifier != null ? element(split(".", data.aws_db_snapshot.atlassian_db_snapshot[0].engine_version), 0) : null
}
