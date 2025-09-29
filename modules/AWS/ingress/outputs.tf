output "outputs" {
  value = {
    r53_zone        = local.domain_supplied ? aws_route53_zone.ingress[0].id : null
    domain          = var.ingress_domain
    certificate_arn = local.domain_supplied ? module.ingress_certificate[0].this_acm_certificate_arn : null
    lb_hostname     = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname
    lb_zone_id      = data.aws_lb.ingress_lb.zone_id
    lb_type         = data.aws_lb.ingress_lb.load_balancer_type
    lb_arn          = data.aws_lb.ingress_lb.arn
  }
}
