locals {
  subnets = [for cidr_block in cidrsubnets(var.vpc_cidr, 2, 2) : cidrsubnets(cidr_block, 2, 2)]

  vpc_tags = {
  }



}

