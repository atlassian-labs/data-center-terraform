locals {
  subnets = [for cidr_block in cidrsubnets(var.vpc_cidr, 2, 2) : cidrsubnets(cidr_block, 2, 2)]

  # tags
  vpc_tags = {
    "Name" : var.vpc_name
  }

  public_subnet_tags = {
    "Name" : "${var.vpc_name}-public-subnets"
  }

  private_subnet_tags = {
    "Name" : "${var.vpc_name}-private-subnets"
  }


}

