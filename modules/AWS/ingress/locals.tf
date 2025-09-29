locals {
  ingress_version      = "4.11.8"
  ingress_name         = "ingress-nginx"
  ingress_namespace    = "ingress-nginx"
  domain_supplied      = var.ingress_domain != null ? true : false
  enable_https_ingress = var.enable_https_ingress
  nat_ip_cidr          = var.load_balancer_access_ranges == ["0.0.0.0/0"] ? [] : formatlist("%s/32", var.vpc.nat_public_ips)
  resource_tags        = join(", ", [for k, v in var.tags : "${k}=${v}"])

  ssh_tcp_setting = var.enable_ssh_tcp ? yamlencode({
    tcp = {
      7999 : "atlassian/bitbucket:ssh"
    }
  }) : yamlencode({})

  load_balancer_annotations = var.enable_ssh_tcp ? {
    # NLB annotations for proper TCP protocol support
    "service.beta.kubernetes.io/aws-load-balancer-type" : "nlb"
    "service.beta.kubernetes.io/aws-load-balancer-scheme" : "internet-facing"
    "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" : "true"
    "service.beta.kubernetes.io/aws-load-balancer-target-type" : "ip"
    "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" : local.resource_tags
    # For NLB, we don't set backend-protocol as it handles TCP natively
  } : {
    # Classic ELB annotations for HTTP traffic
    "service.beta.kubernetes.io/aws-load-balancer-internal" : "false"
    "service.beta.kubernetes.io/aws-load-balancer-ip-address-type" : "dualstack"
    "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" : "http"
    "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" : local.resource_tags
  }

  # the ARN of one or more certificates managed by the AWS Certificate Manager.
  # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/service/annotations/#ssl-cert
  aws_load_balancer_ssl_cert = local.domain_supplied ? yamlencode({
    controller = {
      service = {
        annotations = {
          "service.beta.kubernetes.io/aws-load-balancer-ssl-cert" : module.ingress_certificate[0].this_acm_certificate_arn
          "service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy" : "ELBSecurityPolicy-TLS-1-2-2017-01"
        }
      }
    }
  }) : yamlencode({})

  # The frontend ports with TLS listeners. Specify this annotation if you need
  # both TLS and non-TLS listeners on the same load balancer.
  # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/service/annotations/#ssl-ports
  aws_load_balancer_ssl_ports = local.domain_supplied ? yamlencode({
    controller = {
      service = {
        annotations = {
          "service.beta.kubernetes.io/aws-load-balancer-ssl-ports" : "443"
        }
      }
    }
  }) : yamlencode({})
}
