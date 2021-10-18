data "aws_availability_zones" "available" {
  state = "available"
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "$(var.vpc_name)-vpc"
  cidr = var.vpc_cidr
  azs  = length(var.vpc_azs)>0 ? var.vpc_azs: [data.aws_availability_zones.available.zone_ids[0], data.aws_availability_zones.available.zone_ids[1]]

  private_subnets = var.vpc_private_subnet
  public_subnets  = var.vpc_public_subnet

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

