data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = length(var.vpc_azs)>0 ? var.vpc_azs: [data.aws_availability_zones.available.zone_ids[0], data.aws_availability_zones.available.zone_ids[1]]
  azs_number = max(length(var.vpc_azs), 2)
  subnet_blocks = [for cidr_block in cidrsubnets(var.vpc_cidr, 1, 1) : cidrsubnets(cidr_block, 7, 7, 7, 7, 7, 7)]
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "$(var.vpc_name)-vpc"
  cidr = var.vpc_cidr
  azs  = local.azs

  private_subnets = slice(local.subnet_blocks[0], 0, local.azs_number)
  public_subnets  = slice(local.subnet_blocks[1], 0, local.azs_number)

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = merge(var.required_tags, {
         "kubernetes.io/cluster/${var.vpc_name}": "shared" ,
         "Name"                                 : "${var.vpc_name}-vpc"
       })
  
  public_subnet_tags = merge(var.required_tags, {
    "kubernetes.io/cluster/${var.vpc_name}" = "shared"
    "kubernetes.io/role/elb"                = "1"
  })

  private_subnet_tags = merge(var.required_tags, {
    "kubernetes.io/cluster/${var.vpc_name}" = "shared"
    "kubernetes.io/role/internal-elb"       = "1"
  })

}

