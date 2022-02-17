################################################################################
# Elasticsearch Instance
################################################################################

# Create the elasticsearch based on Elasticsearch Helm charts (https://github.com/elastic/helm-charts/tree/main/elasticsearch)

#resource "helm_release" "elasticsearch" {
#  namespace  = var.namespace
#  repository = local.elasticsearch_helm_chart_repository
#  chart      = "elasticsearch"
#  version    = local.elasticsearch_helm_chart_version
#
#  name = "elasticsearch-${var.environment_name}"
#  values = [
#    yamlencode({
#      name = "elasticsearch",
#
#      antiAffinity = local.antiAffinity
#
#      replicas  = 3,
#      resources = {
#        requests = {
#          cpu    = "250m"
#          memory = "1Gi"
#        }
#      },
#      volumeClaimTemplate = {
#        resources = {
#          requests = {
#            storage = "1Gi"
#          }
#        },
#        persistence = {
#          enabled = "true"
#        },
#        protocol      = "https"
#        httpPort      = 9200
#        transportPort = 9300
#
#        # This is the max unavailable setting for the pod disruption budget
#        # The default value of 1 will make sure that kubernetes won't allow more than 1
#        # of your pods to be unavailable during maintenance
#        maxUnavailable = 1
#
#        # How long to wait for elasticsearch to stop gracefully
#        terminationGracePeriod = 120
#
#      }
#    })
#  ]
#}
