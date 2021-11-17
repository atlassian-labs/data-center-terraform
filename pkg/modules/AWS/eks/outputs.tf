output "cluster_name" {
  value = var.cluster_name
}

output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "kubeconfig_filename" {
  value = module.eks.kubeconfig_filename
}

output "ingress" {
  value = {
    r53_zone        = aws_route53_zone.ingress.id
    domain          = var.ingress_domain
    certificate_arn = module.ingress_certificate.this_acm_certificate_arn
    lb_hostname     = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname
    lb_zone_id      = data.aws_elb.ingress_elb.zone_id
  }
}

output "kubernetes_provider_config" {
  value = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
  sensitive = true
}

output "cluster_security_group" {
  value = module.eks.cluster_security_group_id
}