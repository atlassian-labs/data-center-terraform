# Create the infrastructure for Bamboo Data Center.

# a test instance - should be removed later
//resource "aws_instance" "test-vpc" {
//  ami                    = "ami-221ea342" #id of desired AMI
//  instance_type          = "m3.medium"
//  subnet_id              = var.vpc.subnet_id
//  vpc_security_group_ids = var.vpc.vpc_security_group_ids # list
//  Env = "test"
//}
