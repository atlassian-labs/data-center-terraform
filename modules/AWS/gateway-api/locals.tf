locals {
  domain_supplied = var.ingress_domain != null ? true : false
  gateway_name    = "atlassian-gateway"
  resource_tags   = join(", ", [for k, v in var.tags : "${k}=${v}"])

  envoy_gateway_version = "v1.2.5"
  gateway_api_version   = "1.2.1"
}
