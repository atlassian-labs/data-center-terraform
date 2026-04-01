module "vpc" {
  source = "../AWS/vpc"

  vpc_name = local.vpc_name
}

module "eks" {
  source = "../AWS/eks"

  region                            = var.region_name
  cluster_name                      = local.cluster_name
  eks_version                       = var.eks_version
  tags                              = var.tags
  vpc_id                            = module.vpc.vpc_id
  subnets                           = module.vpc.private_subnets
  instance_types                    = var.instance_types
  instance_disk_size                = var.instance_disk_size
  max_cluster_capacity              = var.max_cluster_capacity
  min_cluster_capacity              = var.min_cluster_capacity
  cluster_downtime_start            = var.cluster_downtime_start
  cluster_downtime_stop             = var.cluster_downtime_stop
  cluster_downtime_timezone         = var.cluster_downtime_timezone
  additional_roles                  = var.eks_additional_roles
  osquery_secret_name               = var.osquery_secret_name
  osquery_secret_region             = var.osquery_secret_region
  osquery_env                       = var.osquery_env
  osquery_version                   = var.osquery_version
  namespace                         = var.namespace
  kinesis_log_producers_role_arns   = var.kinesis_log_producers_role_arns
  confluence_s3_attachments_storage = var.confluence_s3_attachments_storage
  osquery_fleet_enrollment_host     = var.osquery_fleet_enrollment_host
  crowdstrike_secret_name           = var.crowdstrike_secret_name
  crowdstrike_kms_key_name          = var.crowdstrike_kms_key_name
  crowdstrike_aws_account_id        = var.crowdstrike_aws_account_id
  falcon_sensor_version             = var.falcon_sensor_version
}


module "ingress" {
  source     = "../AWS/ingress"
  count      = var.use_gateway_api ? 0 : 1
  depends_on = [module.eks]

  ingress_domain = local.ingress_domain
  enable_ssh_tcp = var.enable_ssh_tcp
  # The ingress module merges this with NAT gateway elastic IPs to ensure
  # ingresses are accessible from within the cluster's pods and nodes.
  load_balancer_access_ranges = var.whitelist_cidr
  enable_https_ingress        = var.enable_https_ingress
  vpc                         = module.vpc
  additional_namespaces       = var.additional_namespaces
  tags                        = var.tags
}

module "gateway" {
  source     = "../AWS/gateway-api"
  count      = var.use_gateway_api ? 1 : 0
  depends_on = [module.eks]

  ingress_domain              = local.ingress_domain
  enable_ssh_tcp              = var.enable_ssh_tcp
  namespace                   = var.namespace
  load_balancer_access_ranges = var.whitelist_cidr
  vpc                         = module.vpc
  additional_namespaces       = var.additional_namespaces
  tags                        = var.tags
  cluster_name                = local.cluster_name
  region                      = var.region_name
}

module "external_dns" {
  source                  = "../AWS/external-dns"
  cluster_name            = local.cluster_name
  create_external_dns     = var.create_external_dns
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  zone_id                 = var.use_gateway_api ? module.gateway[0].outputs.r53_zone : module.ingress[0].outputs.r53_zone
  ingress_domain          = local.ingress_domain
}

resource "kubernetes_namespace" "products" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment" "dcapt_exec" {
  count      = var.start_test_deployment ? 1 : 0
  depends_on = [kubernetes_namespace.products]
  metadata {
    name      = "dcapt"
    namespace = var.namespace
    labels = {
      exec = "true"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        exec = "true"
      }
    }
    template {
      metadata {
        labels = {
          exec = "true"
        }
      }
      spec {
        container {
          name  = "dcapt"
          image = "${var.test_deployment_image_repo}:${var.test_deployment_image_tag}"
          security_context { privileged = true }
          volume_mount {
            mount_path = "/data"
            name       = "data"
          }
          resources {
            requests = {
              cpu    = var.test_deployment_cpu_request
              memory = var.test_deployment_mem_request
            }
            limits = {
              cpu    = var.test_deployment_cpu_limit
              memory = var.test_deployment_mem_limit
            }
          }
          lifecycle {
            post_start {
              exec {
                command = ["/bin/sh", "-c", "apk add --update vim bash git"]
              }
            }
          }
        }
        volume {
          name = "data"
          empty_dir {}
        }
        termination_grace_period_seconds = 0
      }
    }
  }
}

