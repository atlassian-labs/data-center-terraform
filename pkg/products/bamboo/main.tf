# Create the infrastructure for Bamboo Data Center.

# a test instance - should be removed later
//resource "aws_instance" "test-vpc" {
//  ami                    = "ami-221ea342" #id of desired AMI
//  instance_type          = "m3.medium"
//  subnet_id              = var.vpc.subnet_id
//  vpc_security_group_ids = var.vpc.vpc_security_group_ids # list
//  Env = "test"
//}

resource "aws_route53_record" "bamboo" {
  zone_id = local.hosted_zone_id
  name    = local.product_domain_name
  type    = "A"

  alias {
    evaluate_target_health = false
    name                   = local.ingress_load_balancer_hostname
    zone_id                = local.ingress_load_balancer_zone_id
  }
}
