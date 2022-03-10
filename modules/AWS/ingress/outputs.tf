output "outputs" {
  value = {
    r53_zone        = var.ingress_domain != null ? aws_route53_zone.ingress[0].id : null
    domain          = var.ingress_domain
    certificate_arn = var.ingress_domain != null ? module.ingress_certificate[0].this_acm_certificate_arn : null
    lb_hostname     = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname
    lb_zone_id      = data.aws_elb.ingress_elb.zone_id
  }
}
