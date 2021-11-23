locals {
  ingress_name             = "ingress-nginx"
  ingress_namespace        = "ingress-nginx"
  ingress_dns_is_subdomain = length(regexall("[\\w-]+\\.", var.ingress_domain)) == 2
  # This is only used if the DNS is a subdomain
  ingress_dns_domain = replace(var.ingress_domain, "/^[\\w-]+\\./", "")
  ingress_version    = "4.0.6"

  # Apply the eks tags to the autoscaling node group
  worker_groups_tags = flatten([
    for tag_key, tag_value in var.eks_tags : [
      for index in range(length(var.eks_tags)) : {
        key                 = tag_key
        value               = tag_value
        propagate_at_launch = true
      }
      if tag_key != "Name"
    ]
  ])
}

