resource "random_string" "random_password" {
  length  = 10
  special = false
  number  = true
}

resource "helm_release" "postgres" {
  name       = local.postgres_name
  namespace  = var.namespace
  repository = local.postgres_helm_chart_repository
  chart      = "postgresql"
  version    = local.postgres_helm_chart_version

  values = [
    yamlencode({
      global = {
        postgresql = {
          auth = {
            postgresPassword : random_string.random_password.result
            username : "bitbucketuser"
            password : random_string.random_password.result
            database : "bitbucket"
          }
        }
      }
    })
  ]
}
