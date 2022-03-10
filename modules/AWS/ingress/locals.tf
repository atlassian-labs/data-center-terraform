locals {
  ingress_name             = "ingress-nginx"
  ingress_namespace        = "ingress-nginx"
  # This is only used if the DNS is a subdomain
  ingress_version    = "4.0.6"

  ssh_tcp_setting = var.enable_ssh_tcp ? yamlencode({
    tcp = {
      7999 : "atlassian/bitbucket:ssh"
    }
  }) : yamlencode({})

  # the ARN of one or more certificates managed by the AWS Certificate Manager.
  # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/service/annotations/#ssl-cert
  aws_load_balancer_ssl_cert = var.ingress_domain != null ? yamlencode({
    controller = {
      service = {
        annotations = {
          "service.beta.kubernetes.io/aws-load-balancer-ssl-cert" : module.ingress_certificate[0].this_acm_certificate_arn
        }
      }
    }
  }) : yamlencode({})

  # The frontend ports with TLS listeners. Specify this annotation if you need
  # both TLS and non-TLS listeners on the same load balancer.
  # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/service/annotations/#ssl-ports
  aws_load_balancer_ssl_ports = var.ingress_domain != null ? yamlencode({
    controller = {
      service = {
        annotations = {
          "service.beta.kubernetes.io/aws-load-balancer-ssl-ports" : "443"
        }
      }
    }
  }) : yamlencode({})
}
