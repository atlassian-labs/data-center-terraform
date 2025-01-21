data "aws_route_tables" "vpc_route_tables" {
  vpc_id = var.vpc.vpc_id
}

data "aws_network_acls" "vpc_network_acls" {
  vpc_id = var.vpc.vpc_id
}

data "aws_network_interfaces" "vpc_network_interfaces" {
  filter {
    name   = "vpc-id"
    values = [var.vpc.vpc_id]
  }
}
