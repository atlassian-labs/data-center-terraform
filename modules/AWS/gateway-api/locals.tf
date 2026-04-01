locals {
  domain_supplied = var.ingress_domain != null ? true : false
  gateway_name    = "atlassian-gateway"
  resource_tags   = join(", ", [for k, v in var.tags : "${k}=${v}"])
  nat_ip_cidr     = var.load_balancer_access_ranges == ["0.0.0.0/0"] ? [] : formatlist("%s/32", var.vpc.nat_public_ips)
  effective_load_balancer_source_ranges = distinct(concat(
    var.load_balancer_access_ranges,
    local.nat_ip_cidr
  ))

  envoy_gateway_version = "v1.2.5"
  gateway_api_version   = "1.2.1"
}
