locals {
  ingress_version      = "4.10.1"
  ingress_name         = "ingress-nginx"
  ingress_namespace    = "ingress-nginx"
  domain_supplied      = var.ingress_domain != null ? true : false
  enable_https_ingress = var.enable_https_ingress
  nat_ip_cidr          = var.load_balancer_access_ranges == ["0.0.0.0/0"] ? [] : formatlist("%s/32", var.vpc.nat_public_ips)
  resource_tags        = join(", ", [for k, v in var.resource_tags : "${k}=${v}"])

  ssh_tcp_setting = var.enable_ssh_tcp ? yamlencode({
    tcp = {
      7999 : "atlassian/bitbucket:ssh"
    }
  }) : yamlencode({})

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
