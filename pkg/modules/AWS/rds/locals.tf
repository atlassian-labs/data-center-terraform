locals {
  db_master_usr      = "${var.product}user"
  db_jdbc_connection = "jdbc:postgresql://${module.db.db_instance_endpoint}/${module.db.db_instance_name}"
}
