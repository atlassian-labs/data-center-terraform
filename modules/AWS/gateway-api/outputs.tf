output "outputs" {
  value = {
    r53_zone        = local.domain_supplied ? aws_route53_zone.gateway[0].id : null
    domain          = var.ingress_domain
    certificate_arn = local.domain_supplied ? module.gateway_certificate[0].this_acm_certificate_arn : null
    lb_hostname     = data.external.gateway_address.result.hostname
    lb_zone_id      = data.aws_lb.gateway_nlb.zone_id
    gateway_name    = local.gateway_name
    use_gateway_api = true
  }
}
