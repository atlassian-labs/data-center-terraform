locals {
  cluster_name = format("atlas-%s-cluster", var.environment_name)
  namespace    = "atlassian"

  install_jira       = contains([for o in var.products : lower(o)], "jira")
  install_bitbucket  = contains([for o in var.products : lower(o)], "bitbucket")
  install_confluence = contains([for o in var.products : lower(o)], "confluence")
  install_bamboo     = contains([for o in var.products : lower(o)], "bamboo")

  local_bamboo_chart_path = var.local_helm_charts_path != "" && var.bamboo_install_local_chart ? "${var.local_helm_charts_path}/bamboo" : ""
  local_agent_chart_path  = var.local_helm_charts_path != "" && var.bamboo_install_local_chart ? "${var.local_helm_charts_path}/bamboo-agent" : ""
}