locals {
  product_name = "bamboo"

  helm_chart_repository = "https://atlassian.github.io/data-center-helm-charts"
  helm_chart_version    = "0.0.2"

  bamboo_software_resources = {
    "minHeap" : "512m"
    "maxHeap" : "256m"
    "cpu" : "1"
    "mem" : "1Gi"
  }

  bamboo_agent_resources = {
    "cpu" : "0.25"
    "mem" : "256m"
  }

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
      }
    }
  })

  admin_settings = yamlencode({
    bamboo = {
      sysadminCredentials = {
        secretName = kubernetes_secret.admin_secret.metadata[0].name
      }
    }
  })

  unattended_setup_setting = yamlencode({
    bamboo = {
      unattendedSetup = true
    }
  })

  security_token_setting = yamlencode({
    bamboo = {
      securityToken = {
        secretName = kubernetes_secret.security_token_secret.metadata[0].name
      }
      disableAgentAuth = "true"
    }
  })

  dataset_settings = var.dataset_url != null ? yamlencode({
    bamboo = {
      import = {
        type = "import"
        path = "/var/atlassian/application-data/shared-home/${local.dataset_filename}"
      }
    }
  }) : yamlencode({})

  dataset_filename = "dataset_to_import.zip"
}