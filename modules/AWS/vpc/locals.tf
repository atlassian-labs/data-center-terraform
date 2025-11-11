locals {
  # For IPv4, we split the VPC CIDR into 2 parts with 2 bits each, then split each part into 2 more with 2 bits each
  # For IPv6, we use the AWS VPC module's built-in IPv6 subnet allocation
  is_ipv6 = can(regex("^([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:))/([0-9]|[1-9][0-9]|1[0-1][0-9]|12[0-8])$", var.vpc_cidr))
  
  # For IPv4, calculate subnet ranges. For IPv6, we'll let the VPC module handle it
  subnets = local.is_ipv6 ? [[], []] : [for cidr_block in cidrsubnets(var.vpc_cidr, 2, 2) : cidrsubnets(cidr_block, 2, 2)]
}

