locals {
  product_name = "crowd"

  use_local_chart          = fileexists("${var.local_crowd_chart_path}/Chart.yaml")
  helm_chart_repository    = local.use_local_chart ? null : "https://atlassian.github.io/data-center-helm-charts"
  crowd_helm_chart_name    = local.use_local_chart ? var.local_crowd_chart_path : local.product_name
  crowd_helm_chart_version = local.use_local_chart ? null : var.crowd_configuration["helm_version"]

  crowd_software_resources = {
    "minHeap" : var.crowd_configuration["min_heap"]
    "maxHeap" : var.crowd_configuration["max_heap"]
    "cpu" : var.crowd_configuration["cpu"]
    "mem" : var.crowd_configuration["mem"]
  }

  rds_instance_id = format("atlas-%s-%s-db", var.environment_name, local.product_name)

  domain_supplied     = var.ingress.outputs.domain != null ? true : false
  product_domain_name = local.domain_supplied ? "${local.product_name}.${var.ingress.outputs.domain}" : null

  # ingress settings for Crowd service
  ingress_settings = yamlencode({
    ingress = {
      create = "true"
      host   = local.domain_supplied ? "${local.product_name}.${var.ingress.outputs.domain}" : var.ingress.outputs.lb_hostname
      https  = local.domain_supplied ? true : false
      path   = local.domain_supplied ? "/" : "/${local.product_name}"
    }
  })

  crowd_ingress_url = local.domain_supplied ? "https://${local.product_domain_name}" : "http://${var.ingress.outputs.lb_hostname}/${local.product_name}"

  version_tag = var.version_tag != null ? yamlencode({
    image = {
      tag = var.version_tag
    }
  }) : yamlencode({})

  # DC App Performance Toolkit analytics
  dcapt_analytics_property = ["-Dcom.atlassian.dcapt.deployment=terraform"]

  nfs_cluster_service_ipv4 = "172.20.2.6"
}
