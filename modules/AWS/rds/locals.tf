locals {
  db_name = var.snapshot_identifier == null ? var.product : null

  db_master_username = var.db_master_username == null ? "postgres" : var.db_master_username
  db_master_password = var.db_master_password == null ? random_password.password.result : var.db_master_password
  db_jdbc_connection = "jdbc:postgresql://${module.db.db_instance_endpoint}/${var.product}"

  # RDS major version is mapped to the lastest minor version for more details.
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts.General.version13
  engine_version = lookup(
    {
      "10" = "10.19",
      "11" = "11.14",
      "12" = "12.9",
      "13" = "13.5"
  }, var.major_engine_version, "11.14")

  family = lookup(
    {
      "10" = "postgres10",
      "11" = "postgres11",
      "12" = "postgres12",
      "13" = "postgres13"
  }, var.major_engine_version, "postgres11")
}
