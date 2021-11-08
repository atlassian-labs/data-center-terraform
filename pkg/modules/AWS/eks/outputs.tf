output "eks_cluster" {
  value = module.eks
}

output "r53_zone" {
  value = aws_route53_zone.ingress.id
}