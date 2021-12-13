locals {
  product_name = "bamboo"

  rds_instance_name = format("atlas-%s-%s-db", var.environment_name, local.product_name)

  # if the domain wasn't provided we will start Bamboo with LoadBalancer service without ingress configuration
  use_domain          = length(var.ingress) == 1
  product_domain_name = local.use_domain ? "${local.product_name}.${var.ingress[0].ingress.domain}" : null
  # ingress settings for Bamboo service
  ingress_with_domain = yamlencode({
    ingress = {
      create = "true"
      host   = local.product_domain_name
    }
  })

  service_as_loadbalancer = yamlencode({
    bamboo = {
      service = {
        type = "LoadBalancer"
      }
    }
    ingress = {
      https = false
    }
  })

  ingress_settings   = local.use_domain ? local.ingress_with_domain : local.service_as_loadbalancer
  storage_class_name = "efs-cs"

  license_settings = yamlencode({
    bamboo = {
      license = {
        secretName = kubernetes_secret.license_secret.metadata[0].name
        secretKey  = "license"
      }
    }
  })

  admin_settings = yamlencode({
    bamboo = {
      sysadminCredentials = {
        secretName            = kubernetes_secret.admin_secret.metadata[0].name
        usernameSecretKey     = kubernetes_secret.admin_secret.data.username
        passwordSecretKey     = kubernetes_secret.admin_secret.data.password
        displayNameSecretKey  = kubernetes_secret.admin_secret.data.displayName
        emailAddressSecretKey = kubernetes_secret.admin_secret.data.emailAddress
      }
    }
  })
}