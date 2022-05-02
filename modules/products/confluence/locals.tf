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

  synchrony_ingress_url = local.domain_supplied ? "${local.confluence_ingress_url}/synchrony" : "http://${var.ingress.outputs.lb_hostname}/${local.product_name}/synchrony"

  synchrony_settings_stanza = yamlencode({
    synchrony = {
      enabled    = true
      ingressUrl = local.synchrony_ingress_url
    }
  })

  # Confluence version tag
  version_tag = var.version_tag != null ? yamlencode({
    image = {
      tag = var.version_tag
    }
  }) : yamlencode({})

  # Provide additional environment variables to Confluence Helm chart to skip setup wizard when restoring database from snapshot.
  db_restore_env_vars = var.db_snapshot_identifier != null ? yamlencode({
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

  # After restoring the snapshot of the Confluence database, a re-index is required. An alternative is recover the index.
  # Because there is no node existed when the environment is created, so index recovery cannot be borrow the files from other nodes
  # and is forced to use the recovery journal files from shared home.
  # By default recovery index files are only valid for 2 days which is not enough in our use case.
  # One way for extend the validity duration for index recovery file is override the `com.atlassian.confluence.journal.timeToLiveInMillis`
  # system property. Also we may need to extend the index recovery timeout as for enterprise data we may hit the timeout and it will
  # results a failure in index recovery and Confluence will start a full re-index which is not efficient.
  # For more info see the following links:
  # https://confluence.atlassian.com/conf78/recognized-system-properties-1021242818.html
  # https://extranet.atlassian.com/pages/viewpage.action?pageId=4215563160
  # https://extranet.atlassian.com/pages/viewpage.action?spaceKey=CONFARCH&title=Index+recovery


  # TODO: For permanent solution we may get the snapshot creation date in advanced and calculate the required validity duration (in milliseconds) and set `timeToLiveInMillis`
  # For now I hard coded based on the test snapshot which is created by May 2nd to complete my tests

  date_year     = tonumber(formatdate("YYYY", timestamp())) # current year
  date_month     = tonumber(formatdate("MM", timestamp())) # current year
  date_days     = tonumber(formatdate("DD", timestamp())) # current year
  day_in_millis = 24 * 360 * 10000
  # hardcode the snapshot creation date
  snapshot_creation_year  = 2022
  snapshot_creation_month = 5
  snapshot_creation_day   = 1
  # Calculate the time passed from snapshot creation in milliseconds
  offset       = ((local.snapshot_creation_month - 1 ) * 30) + local.snapshot_creation_day * local.day_in_millis # the snapshot I used is generated on May 2nd, so we can deduct 4 months from the following calculation
  time_to_live = ((local.date_year - local.snapshot_creation_year - 1) * 365 + local.date_month * 30 + local.date_days) * local.day_in_millis - local.offset  # valid duration for ebs snapshot in milliseconds

  extend_snapshot_validity = var.db_snapshot_identifier != null ? yamlencode({
    confluence = {
      additionalJvmArgs = [
        "-Dcom.atlassian.confluence.journal.timeToLiveInMillis=${local.time_to_live}",
        "-Dconfluence.cluster.index.recovery.query.timeout=360",
        "-Dconfluence.cluster.index.recovery.generation.timeout=420",
        "-Dconfluence.cluster.snapshot.file.wait.time=420"
      ]
    }
  }) : yamlencode({})

  # optimum number of threads used for re-index will calculated using this formula: `CPUs x 0.5 x (1 + WC)`, while WC is a constant equals to 0.8
  number_of_threads = min(4, floor(tonumber(confluence_configuration["cpu"]) x 0.5 x (1 + 0.8)))

  extend_reindex_thread_counts = var.db_snapshot_identifier != null ? yamlencode({
    confluence = {
      additionalJvmArgs = [
        "-Dreindex.thread.count=${local.number_of_threads}",
        "-Dindex.queue.thread.count=${local.number_of_threads}",
        "-Dreindex.attachments.thread.count=${local.number_of_threads}",
      ]
    }
  }) : yamlencode({})

}
