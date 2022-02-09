locals {
  cluster_name = format("atlas-%s-cluster", var.environment_name)
  namespace    = "atlassian"

  install_jira       = contains([for o in var.products : lower(o)], "jira")
  install_bitbucket  = contains([for o in var.products : lower(o)], "bitbucket")
  install_confluence = contains([for o in var.products : lower(o)], "confluence")
  install_bamboo     = contains([for o in var.products : lower(o)], "bamboo")

}