locals {
  product_name = "bamboo"

  required_tags = {
    product : local.product_name
  }

  product_tags = {
    Name : local.product_name
  }

  rds_instance_name = format("atlassian-dc-%s-%s-db", var.environment_name, local.product_name)

  # if the domain wasn't provided we will start Bamboo with LoadBalancer service without ingress configuration
  use_domain          = length(var.ingress) == 1
  product_domain_name = local.use_domain ? "${local.product_name}.${var.ingress[0].ingress.domain}" : null
  ingress_settings = local.use_domain ? yamlencode({
    ingress = {
      create = "true"
      host   = local.product_domain_name
    }
    }) : yamlencode({
    bamboo = {
      service = {
        type = "LoadBalancer"
      }
    }
  })
}