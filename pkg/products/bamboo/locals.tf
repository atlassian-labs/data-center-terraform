locals {
  product_name   = "bamboo"
  cluster_name  = format("%s-%s-%s", var.environment_name, local.product_name, "cluster")
  vpc_name      = format("%s-%s-%s", var.environment_name, local.product_name, "vpc")

  required_tags = {
    product : local.product_name
  }

  product_tags = {
    Name    : local.product_name
  }


  # Look at https://hello.atlassian.net/wiki/spaces/RELENG/pages/677332161/HOWTO%3A+IAM+Roles+in+PBC+%28Bamboo%29+using+IRSA
  # to find out how to modify these variables.
  # TLDR: The OIDC ARN can be found in the "Identity Providers" sub-menu in the AWS IAM console.
  build_role_oidc_arn = "arn:aws:iam::342470128466:oidc-provider/oidc-atlassian-kubernetes-cicd-prod.s3.us-east-1.amazonaws.com"
  build_role_builds = [
    # This value has to be defined for each build. It can be found by going to the build in Bamboo, clicking "Actions"
    # on the top right and choosing "View AWS IAM Subject ID for PBC"
    "kubernetes.cicd.buildeng-server-syd-bamboo.server-syd-bamboo/DCD-K8SHELMTEST/B/5307728059"
  ]

  # Additional IAM roles to add to the aws-auth configmap. See modules/eks/variables.tf for details.
  additional_map_roles = [
    {
      rolearn  = "arn:aws:iam::887764444972:role/dcd-private-sysadmin"
      username = "dcd-private-sysadmin"
      groups = [
        "system:masters"
      ]
    }
  ]

  # The value of OSQUERY_ENV that will be used to send logs to Splunk. It should not be something like “production”
  # or “prod-west2” but should instead relate to the product, platform, or team.
  osquery_env = "osquery_dcd_infrastructure"
}