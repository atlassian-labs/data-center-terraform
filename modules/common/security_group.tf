resource "aws_security_group" "vpc" {
  name_prefix = format("%s_sg", local.vpc_name)
  description = "VPC security group with IPv4 and IPv6 support."
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow all outbound traffic (IPv4 and IPv6)"
  }

  tags = {
    Name = format("%s_sg", local.vpc_name)
  }
}