data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.9.0"

  name = var.vpc_name
  cidr = var.vpc_cidr
  azs  = [data.aws_availability_zones.available.zone_ids[0], data.aws_availability_zones.available.zone_ids[1]]

  private_subnets = local.subnets[0]
  public_subnets  = local.subnets[1]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Enable IPv6 support
  enable_ipv6                     = true
  assign_ipv6_address_on_creation = true
  
  # Enable IPv6 DNS support
  enable_dns_support = true
  
  # Create IPv6-enabled subnets with Amazon-provided IPv6 CIDR blocks
  create_egress_only_igw          = true
  enable_ipv6_public_subnet       = true
  enable_ipv6_private_subnet      = true
  public_subnet_ipv6_prefixes     = [0, 1]
  private_subnet_ipv6_prefixes    = [2, 3]

  public_subnet_suffix  = "public-subnet"
  private_subnet_suffix = "private-subnet"

  # Tags for subnets to support EKS
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
