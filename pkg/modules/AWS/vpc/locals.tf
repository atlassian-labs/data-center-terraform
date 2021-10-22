locals {
  # Pick the default azs if azs list is not provided
  azs = length(var.vpc_azs)>0 ? var.vpc_azs: [data.aws_availability_zones.available.zone_ids[0], data.aws_availability_zones.available.zone_ids[1]]

  # Calculate subnets based on vpc_cidr if they are not provided
  # Split the cidr block in two equal blocks, and divide each part into smaller chunks.
  azs_number = max(length(var.vpc_azs), 2)
  subnet_blocks = [for cidr_block in cidrsubnets(var.vpc_cidr, 1, 1) : cidrsubnets(cidr_block, 3, 3, 3, 3, 3, 3, 3, 3)]
  private_subnets = length(var.vpc_private_subnets)>0 ? var.vpc_private_subnets : slice(local.subnet_blocks[0], 0, local.azs_number)
  public_subnets = length(var.vpc_public_subnets)>0 ? var.vpc_public_subnets : slice(local.subnet_blocks[1], 0, local.azs_number)

  # tags
  vpc_tags = {
    "Name"                                     : var.vpc_name
  }

  public_subnet_tags = {
    "Name"                                      : "${var.vpc_name}-public-subnets"
    "kubernetes.io/role/elb"                    : "1"
  }

  private_subnet_tags = {
    "Name"                                      : "${var.vpc_name}-private-subnets"
    "kubernetes.io/role/internal-elb"           : "1"
  }

  product_tags = {
    "Name" : "${var.vpc_name}-${var.product_name}"
  }
}
