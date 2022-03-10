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

  domain_supplied     = var.ingress.ingress.domain != null ? true : false
  product_domain_name = local.domain_supplied ? "${local.product_name}.${var.ingress.ingress.domain}" : null

  # ingress settings for Bamboo service
  ingress_settings = yamlencode({
    ingress = {
      create = "true"
      host   = local.domain_supplied ? "${local.product_name}.${var.ingress.ingress.domain}" : var.ingress.ingress.lb_hostname
      https  = local.domain_supplied ? true : false
      path   = local.domain_supplied ? null : "/bamboo"
    }
  })

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

  # Bamboo version tag
  version_tag = var.version_tag != null ? yamlencode({
    image = {
      tag = var.version_tag
    }
  }) : yamlencode({})

  # Bamboo agent version tag
  agent_version_tag = var.agent_version_tag != null ? yamlencode({
    image = {
      tag = var.agent_version_tag
    }
  }) : yamlencode({})

  dataset_filename = "bamboo_dataset_to_import.zip"
  sub_path         = "${local.product_name}-${random_string.random.result}"
}
