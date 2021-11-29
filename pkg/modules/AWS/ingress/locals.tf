locals {
  ingress_name             = "ingress-nginx"
  ingress_namespace        = "ingress-nginx"
  ingress_dns_is_subdomain = length(regexall("[\\w-]+\\.", var.ingress_domain)) == 2
  # This is only used if the DNS is a subdomain
  ingress_dns_domain = replace(var.ingress_domain, "/^[\\w-]+\\./", "")
  ingress_version    = "4.0.6"
}