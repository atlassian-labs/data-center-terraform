locals {
  ingress_name             = "ingress-nginx"
  ingress_namespace        = "ingress-nginx"
  ingress_dns_is_subdomain = length(regexall("[\\w-]+\\.", var.ingress_domain)) == 2
  # This is only used if the DNS is a subdomain
  ingress_dns_domain = replace(var.ingress_domain, "/^[\\w-]+\\./", "")
  ingress_version    = "4.0.6"
  # ec2_formatted_tags = flatten( [for id in data.aws_instances.ec2.ids : [for key, value in data.aws_default_tags.current.tags : {
  #   tag_key : key
  #   tag_value : value
  #   resource_id : id
  #   iteration_id : "${id}-${key}"
  #   }
  # ]])
}