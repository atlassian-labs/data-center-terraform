#module "cluster_autoscaler" {
#  source = "git::https://github.com/DNXLabs/terraform-aws-eks-cluster-autoscaler.git"
#
#  enabled = true
#
#  cluster_name                     = module.eks.cluster_id
#  cluster_identity_oidc_issuer     = module.eks.cluster_oidc_issuer_url
#  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
#  aws_region                       = data.aws_region.current.name
#}