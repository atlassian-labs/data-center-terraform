locals {
  vpc_name       = format("atlas-%s-vpc", var.environment_name)
  cluster_name   = format("atlas-%s-cluster", var.environment_name)
  ingress_domain = var.domain != null ? "${var.environment_name}.${var.domain}" : null
  nat_ip_cidr    = var.whitelist_cidr == ["0.0.0.0/0"] ? [] : formatlist("%s/32", module.vpc.nat_public_ips)
}
