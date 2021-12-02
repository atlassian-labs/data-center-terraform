resource "aws_security_group" "vpc" {
  name_prefix = format("%s_sg", local.vpc_name)
  description = "VPC security group."
  vpc_id      = module.vpc.vpc_id
}