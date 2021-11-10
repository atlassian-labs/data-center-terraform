locals {
  cidr    = "10.0.0.0/18"
  subnets = [for cidr_block in cidrsubnets(local.cidr, 2, 2) : cidrsubnets(cidr_block, 2, 2)]

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

