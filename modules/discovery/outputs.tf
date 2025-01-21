output "route_table_ids" {
  value = data.aws_route_tables.vpc_route_tables.ids
}

output "network_interface_ids" {
  value = data.aws_network_interfaces.vpc_network_interfaces.ids
}

output "network_acl_ids" {
  value = data.aws_network_acls.vpc_network_acls.ids
}
