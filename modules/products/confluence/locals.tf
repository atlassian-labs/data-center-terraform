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

  # Current date - the date the index recovery files are going to be used
  date_year  = tonumber(formatdate("YYYY", timestamp())) # current year
  date_month = tonumber(formatdate("MM", timestamp())) # current year
  date_days  = tonumber(formatdate("DD", timestamp())) # current year
  day_millis = 24 * 360 * 10000 # number of milliseconds in a day
  # Get the snapshot creation date
  creation_date  = split("-", var.shared_home_snapshot_creation_date)
  snapshot_year  = tonumber(local.creation_date[0])
  snapshot_month = tonumber(local.creation_date[1])
  snapshot_day   = tonumber(local.creation_date[2])
  # Calculate the days passed from snapshot creation + 7 days extra
  offset       = ((local.snapshot_month - 1 ) * 30) + local.snapshot_day
  days_from_snapshot = (local.date_year - local.snapshot_year) * 365 + local.date_month * 30 + local.date_days - local.offset + 7

  # Override the lifetime of recovery index in shared home and make sure there is enough timeout for copy long files
  extend_snapshot_validity = var.db_snapshot_identifier != null ? yamlencode({
    confluence = {
      additionalJvmArgs = [
        "-Dcom.atlassian.confluence.journal.timeToLiveInMillis=${local.days_from_snapshot * local.day_millis}", # milliseconds
        "-Dconfluence.cluster.index.recovery.generation.timeout=480", # seconds
        "-Dconfluence.cluster.snapshot.file.wait.time=480", # seconds
      ]
    }
  }) : yamlencode({})

  number_of_threads = min(4, floor(tonumber(local.confluence_software_resources.cpu)))

  # Set the number of threads to boost re-index process based on number of Confluence CPUs per node
  extend_reindex_thread_counts = yamlencode({
    confluence = {
      additionalJvmArgs = [
        "-Dreindex.thread.count=${local.number_of_threads}",
        "-Dindex.queue.thread.count=${local.number_of_threads}",
        "-Dreindex.attachments.thread.count=${local.number_of_threads}",
      ]
    }
  })

}
