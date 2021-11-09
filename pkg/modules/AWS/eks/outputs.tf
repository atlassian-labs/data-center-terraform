output "eks_cluster" {
  value = module.eks
}

output "ingress" {
  value = {
    r53_zone    = aws_route53_zone.ingress.id
    domain      = var.ingress_domain
    lb_hostname = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname
    lb_zone_id  = data.aws_elb.ingress_elb.zone_id
  }
}