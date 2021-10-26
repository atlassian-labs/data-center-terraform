locals {
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

