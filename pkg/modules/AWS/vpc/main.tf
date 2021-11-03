data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.10.0"

  name = var.vpc_name
  cidr = "10.0.0.0/20"
  azs  = [data.aws_availability_zones.available.zone_ids[0], data.aws_availability_zones.available.zone_ids[1]]

  private_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
  public_subnets  = ["10.0.8.0/24", "10.0.9.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = merge(var.vpc_tags, local.vpc_tags)

  public_subnet_tags  = merge(var.vpc_tags, local.public_subnet_tags)
  private_subnet_tags = merge(var.vpc_tags, local.private_subnet_tags)

}

