module "vpc" {
  source = "../AWS/vpc"

  vpc_name = local.vpc_name
}

module "eks" {
  source = "../AWS/eks"

  region                          = var.region_name
  cluster_name                    = local.cluster_name
  eks_version                     = var.eks_version
  tags                            = var.tags
  vpc_id                          = module.vpc.vpc_id
  subnets                         = module.vpc.private_subnets
  instance_types                  = var.instance_types
  instance_disk_size              = var.instance_disk_size
  max_cluster_capacity            = var.max_cluster_capacity
  min_cluster_capacity            = var.min_cluster_capacity
  cluster_downtime_start          = var.cluster_downtime_start
  cluster_downtime_stop           = var.cluster_downtime_stop
  cluster_downtime_timezone       = var.cluster_downtime_timezone
  additional_roles                = var.eks_additional_roles
  osquery_secret_name             = var.osquery_secret_name
  osquery_secret_region           = var.osquery_secret_region
  osquery_env                     = var.osquery_env
  osquery_version                 = var.osquery_version
  kinesis_log_producers_role_arns = var.kinesis_log_producers_role_arns
  osquery_fleet_enrollment_host   = var.osquery_fleet_enrollment_host

}


module "ingress" {
  source     = "../AWS/ingress"
  depends_on = [module.eks]

  # inputs
  ingress_domain = local.ingress_domain
  enable_ssh_tcp = var.enable_ssh_tcp
  # we need to merge the list of cidrs provided in config.tfvars with the list of nat elastic IPs
  # to make sure ingresses are available when accessed from within pods and nodes of the cluster
  load_balancer_access_ranges = var.whitelist_cidr
  enable_https_ingress        = var.enable_https_ingress
  vpc                         = module.vpc
  additional_namespaces       = var.additional_namespaces
}

module "external_dns" {
  source                  = "../AWS/external-dns"
  cluster_name            = local.cluster_name
  create_external_dns     = true
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  zone_id                 = module.ingress.outputs.r53_zone
  ingress_domain          = local.ingress_domain
}

resource "kubernetes_namespace" "products" {
  metadata {
    name = var.namespace
  }
}
