locals {
  product_name = "bamboo"
  agent_name   = "bamboo-agent"

  # Install local bamboo/agent helm charts if local path is provided
  use_local_bamboo = fileexists("${var.local_bamboo_chart_path}/Chart.yaml")
  use_local_agent  = fileexists("${var.local_bamboo_chart_path}/Chart.yaml")

  helm_chart_repository     = local.use_local_bamboo ? null : "https://atlassian.github.io/data-center-helm-charts"
  bamboo_helm_chart_name    = local.use_local_bamboo ? var.local_bamboo_chart_path : local.product_name
  bamboo_helm_chart_version = local.use_local_bamboo ? null : var.bamboo_configuration["helm_version"]

  agent_helm_chart_name    = local.use_local_agent ? var.local_agent_chart_path : local.agent_name
  agent_helm_chart_version = local.use_local_agent ? null : var.bamboo_agent_configuration["helm_version"]
  number_of_agents         = var.bamboo_agent_configuration["agent_count"]

  bamboo_software_resources = {
    "minHeap" : var.bamboo_configuration["min_heap"]
    "maxHeap" : var.bamboo_configuration["max_heap"]
    "cpu" : var.bamboo_configuration["cpu"]
    "mem" : var.bamboo_configuration["mem"]
  }

  bamboo_agent_resources = {
    "cpu" : var.bamboo_agent_configuration["cpu"]
    "mem" : var.bamboo_agent_configuration["mem"]
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

  ingress_settings = local.use_domain ? local.ingress_with_domain : local.service_as_loadbalancer

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
