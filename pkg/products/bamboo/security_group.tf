resource aws_security_group vpc {
  name_prefix = format("%s_%s", local.vpc_name, local.product_name)
  description = "VPC security group."
  vpc_id = module.vpc.vpc_id

  tags = merge(var.required_tags, local.product_tags)
}