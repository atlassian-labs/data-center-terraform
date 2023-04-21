locals {
  product_name = "confluence"

  # Install local confluence helm charts if local path is provided
  use_local_chart = fileexists("${var.local_confluence_chart_path}/Chart.yaml")

  helm_chart_repository         = local.use_local_chart ? null : "https://atlassian.github.io/data-center-helm-charts"
  confluence_helm_chart_name    = local.use_local_chart ? var.local_confluence_chart_path : local.product_name
  confluence_helm_chart_version = local.use_local_chart ? null : var.confluence_configuration["helm_version"]

  confluence_software_resources = {
    "minHeap" : var.confluence_configuration["min_heap"]
    "maxHeap" : var.confluence_configuration["max_heap"]
    "cpu" : var.confluence_configuration["cpu"]
    "mem" : var.confluence_configuration["mem"]
  }

  synchrony_resources = {
    "minHeap" : var.synchrony_configuration["min_heap"]
    "maxHeap" : var.synchrony_configuration["max_heap"]
    "stackSize" : var.synchrony_configuration["stack_size"]
    "cpu" : var.synchrony_configuration["cpu"]
    "mem" : var.synchrony_configuration["mem"]
  }

  rds_instance_name = format("atlas-%s-%s-db", var.environment_name, local.product_name)

  domain_supplied     = var.ingress.outputs.domain != null ? true : false
  product_domain_name = local.domain_supplied ? "${local.product_name}.${var.ingress.outputs.domain}" : null

  # ingress settings for confluence service
  ingress_settings = yamlencode({
    ingress = {
      create = "true"
      host   = local.domain_supplied ? "${local.product_name}.${var.ingress.outputs.domain}" : var.ingress.outputs.lb_hostname
      https  = local.domain_supplied ? true : false
      path   = local.domain_supplied ? null : "/${local.product_name}"
    }
  })

  context_path_settings = !local.domain_supplied ? yamlencode({
    confluence = {
      service = {
        contextPath = "/${local.product_name}"
      }
    }
  }) : yamlencode({})

  license_settings = var.confluence_configuration["license"] != null ? yamlencode({
    confluence = {
      license = {
        secretName = kubernetes_secret.license_secret.metadata[0].name
      }
    }
  }) : yamlencode({})

  confluence_ingress_url = local.domain_supplied ? "https://${local.product_domain_name}" : "http://${var.ingress.outputs.lb_hostname}/${local.product_name}"

  synchrony_ingress_url = local.domain_supplied ? "${local.confluence_ingress_url}/synchrony" : "http://${var.ingress.outputs.lb_hostname}/synchrony"

  synchrony_settings_stanza = yamlencode({
    synchrony = {
      enabled = true
    }
  })

  # Confluence version tag
  version_tag = var.version_tag != null ? yamlencode({
    image = {
      tag = var.version_tag
    }
  }) : yamlencode({})

  # Provide additional environment variables to Confluence Helm chart to skip setup wizard when restoring database from snapshot.
  db_restore_env_vars = var.db_snapshot_id != null ? yamlencode({
    confluence = {
      additionalEnvironmentVariables = [
        {
          name  = "ATL_SETUP_STEP",
          value = "complete"
        },
        {
          name  = "ATL_SETUP_TYPE",
          value = "cluster"
        },
        {
          name  = "ATL_BUILD_NUMBER",
          value = var.db_snapshot_build_number
        },
        {
          name  = "ATL_SNAPSHOT_USED",
          value = "true"
        },
      ]
    }
  }) : yamlencode({})


  # updates base url (in case we are restoring from snapshot)
  db_master_username = var.db_master_username == null ? module.database.rds_master_username : var.db_master_username
  db_master_password = var.db_master_password == null ? module.database.rds_master_password : var.db_master_password
  cmd_psql_update    = "BASE_URL_TO_REPLACE=$(PGPASSWORD=${local.db_master_password} psql postgresql://${module.database.rds_endpoint}/${local.product_name} -U ${local.db_master_username} -Atc \"select BANDANAVALUE from BANDANA where BANDANACONTEXT = '_GLOBAL' and BANDANAKEY = 'atlassian.confluence.settings';\" | grep -i '<baseurl>'); PGPASSWORD=${local.db_master_password} psql postgresql://${module.database.rds_endpoint}/${local.product_name} -U ${local.db_master_username} -c \"update BANDANA set BANDANAVALUE = replace(BANDANAVALUE, '$${BASE_URL_TO_REPLACE}', '<baseUrl>${local.confluence_ingress_url}</baseUrl>') where BANDANACONTEXT = '_GLOBAL' and BANDANAKEY = 'atlassian.confluence.settings';\""

  # updates license in shared home (in case we are restoring from snapshot)
  cmd_license_update = "sed -i 's|<property name=\"atlassian.license.message\">.*</property>|<property name=\"atlassian.license.message\">${var.confluence_configuration["license"]}</property>|g' /shared-home/confluence.cfg.xml"

  # DC App Performance Toolkit analytics
  dcapt_analytics_property = ["-Dcom.atlassian.dcapt.deployment=terraform"]

  irsa_properties = var.confluence_s3_attachments_storage ? ["-Daws.webIdentityTokenFile=/var/run/secrets/eks.amazonaws.com/serviceaccount/token",
    "-Dconfluence.filestore.attachments.s3.bucket.name=${var.eks.confluence_s3_bucket_name}",
    "-Dconfluence.filestore.attachments.s3.bucket.region=${var.region_name}"] : []

  service_account_annotations = var.confluence_s3_attachments_storage ? yamlencode({
    serviceAccount = {
      annotations = {
        "eks.amazonaws.com/role-arn" = var.eks.confluence_s3_role_arn
      }
    }
  }) : yamlencode({})

  nfs_cluster_service_ipv4 = "172.20.2.4"
}
