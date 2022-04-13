locals {
  product_name = "jira"

  helm_chart_repository   = "https://atlassian.github.io/data-center-helm-charts"
  jira_helm_chart_version = var.jira_configuration["helm_version"]

  jira_software_resources = {
    "minHeap" : var.jira_configuration["min_heap"]
    "maxHeap" : var.jira_configuration["max_heap"]
    "cpu" : var.jira_configuration["cpu"]
    "mem" : var.jira_configuration["mem"]
    "reservedCodeCache" : var.jira_configuration["reserved_code_cache"]
  }

  rds_instance_id = format("atlas-%s-%s-db", var.environment_name, local.product_name)

  domain_supplied     = var.ingress.outputs.domain != null ? true : false
  product_domain_name = local.domain_supplied ? "${local.product_name}.${var.ingress.outputs.domain}" : null

  # ingress settings for Jira service
  ingress_settings = yamlencode({
    ingress = {
      create = "true"
      host   = local.domain_supplied ? "${local.product_name}.${var.ingress.outputs.domain}" : var.ingress.outputs.lb_hostname
      https  = local.domain_supplied ? true : false
      path   = local.domain_supplied ? null : "/${local.product_name}"
    }
  })

  jira_ingress_url = local.domain_supplied ? "https://${local.product_domain_name}" : "http://${var.ingress.outputs.lb_hostname}/${local.product_name}"

  context_path_settings = !local.domain_supplied ? yamlencode({
    jira = {
      service = {
        contextPath = "/${local.product_name}"
      }
    }
  }) : yamlencode({})

  version_tag = var.version_tag != null ? yamlencode({
    image = {
      tag = var.version_tag
    }
  }) : yamlencode({})

  # After restoring the snapshot of the Jira database, a re-index is required. To avoid interruption in the Jira
  # service we should exclude indexing status from the health check process.
  # For more info see: https://jira.atlassian.com/browse/JRASERVER-66970
  ignore_index_check = var.db_snapshot_identifier != null ? yamlencode({
    jira = {
      additionalJvmArgs = ["-Dcom.atlassian.jira.status.index.check=false"]
    }
  }) : yamlencode({})

  license = "AAAB8Q0ODAoPeNp9Uk1z2jAQvetXaKY3ZmSMSRrKjA+JraZkgu2xTTv9Ogh7AVEjeSSZ1P++wpi2CSQHHbQfb9++t+++QIlva4VHY+yOp9eTqTfB9/Mce67nobUCEBtZ16CcR16A0EBLbrgUPo1ymibpLKMoanZLUPFqoUFpf+SiQArDChOxHfjbLUixRkmjig3TEDID/gGbuFdkNEY9at7W0JWH9DN9jBOanjL0d81V27UlI8/9dAKnc8arE3oGag9qFvp39IaSq/CbR97HDzfkfvxhgrZcMadWsmwK4xw+RMuVeWIKHIvD9+Ab1QB6sJmkr7LjWADCvCjJmqUuFK87AbrIBYEurNIxeF2/wWAQxTn5GKckSeNwEeSzOCKLjNqEHyiwu5d42WKzAdyjYCoKWYLCdq8tFAZ/3xhT/5gOh2vpMFMxrTkTTiF3w+rYQeDY8dPBocRCGlxybRRfNgYsMtfYSFw02sidddFBVl5hQDBRnFtgeQUpvc1pSO6+Hkj2Nryh9NmN9ItYzxbil5BPAmU08u0j1657RDq5AOpc7Mww9TfxxtxndbFaM8E16wyYtziQu5qJFnUa29jL4wzhn905aIN7LfFKWuWrZs0FLmEPlbSU9DN+/59NR+8scJnv60dE96xqjtRXrNKA/gDQakzsMCwCFG8JD+9JKcQy6O+SAw69it4/5qBuAhQCz6xRgHMTic87Kqty52VlAGeQxw==X02nj"
}