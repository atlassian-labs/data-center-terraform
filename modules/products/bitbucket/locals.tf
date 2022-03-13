locals {
  product_name = "bitbucket"

  helm_chart_repository        = "https://atlassian.github.io/data-center-helm-charts"
  bitbucket_helm_chart_version = var.bitbucket_configuration["helm_version"]

  bitbucket_software_resources = {
    "minHeap" : var.bitbucket_configuration["min_heap"]
    "maxHeap" : var.bitbucket_configuration["max_heap"]
    "cpu" : var.bitbucket_configuration["cpu"]
    "mem" : var.bitbucket_configuration["mem"]
  }

  admin_settings = length(kubernetes_secret.admin_secret) == 1 ? yamlencode({
    bitbucket = {
      sysadminCredentials = {
        secretName = kubernetes_secret.admin_secret[0].metadata[0].name
      }
    }
  }) : yamlencode({})

  rds_instance_name = format("atlas-%s-%s-db", var.environment_name, local.product_name)

  domain_supplied     = var.ingress.outputs.domain != null ? true : false
  product_domain_name = local.domain_supplied ? "${local.product_name}.${var.ingress.outputs.domain}" : null

  # ingress settings for bitbucket service
  ingress_settings = yamlencode({
    ingress = {
      create = "true"
      host   = local.domain_supplied ? "${local.product_name}.${var.ingress.outputs.domain}" : var.ingress.outputs.lb_hostname
      https  = local.domain_supplied ? true : false
      path   = local.domain_supplied ? null : "/${local.product_name}"
    }
  })

  context_path_settings = !local.domain_supplied ? yamlencode({
    bitbucket = {
      service = {
        contextPath = "/${local.product_name}"
      }
    }
  }) : yamlencode({})

  # license settings
  license_settings = var.bitbucket_configuration["license"] != null ? yamlencode({
    bitbucket = {
      license = {
        secretName = kubernetes_secret.license_secret.metadata[0].name
      }
    }
  }) : yamlencode({})

  # bitbucket version tag
  version_tag = var.version_tag != null ? yamlencode({
    image = {
      tag = var.version_tag
    }
  }) : yamlencode({})

  # Elasticsearch
  elasticsearch_name                  = "elasticsearch"
  elasticsearch_helm_chart_repository = "https://helm.elastic.co"
  elasticsearch_helm_chart_version    = "7.16.3"
  elasticsearch_antiAffinity          = var.eks.cluster_size < 3 ? "soft" : "hard"

  elasticsearch_endpoint = var.elasticsearch_endpoint == null ? "http://${local.elasticsearch_name}-master:9200" : var.elasticsearch_endpoint
  minimumMasterNodes     = var.elasticsearch_replicas == 1 ? 1 : 2

  single_mode_elasticsearch = var.elasticsearch_replicas > 1 ? yamlencode({}) : yamlencode({
    extraEnvs = [
      { name = "discovery.type", value = "single-node" },
      { name = "cluster.initial_master_nodes", value = "" }
    ]
  })

  # Bitbucket display name
  display_name = var.display_name != null ? yamlencode({
    bitbucket = {
      displayName = var.display_name
    }
  }) : yamlencode({})
}
