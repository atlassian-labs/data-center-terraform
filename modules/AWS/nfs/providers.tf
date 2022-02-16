#provider "helm" {
#  kubernetes {
##    host                   = var.eks.kubernetes_provider_config.host
##    token                  = var.eks.kubernetes_provider_config.token
##    cluster_ca_certificate = var.eks.kubernetes_provider_config.cluster_ca_certificate
#
#    host                   = data.aws_eks_cluster.cluster.endpoint
#    token                  = data.aws_eks_cluster_auth.cluster.token
#    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#  }
#}
#
#
#### FOR TEST ONLY ####
#data "aws_eks_cluster" "cluster" {
#  name = "dcd-ci-k8s"
#}
#
#data "aws_eks_cluster_auth" "cluster" {
#  name = "dcd-ci-k8s"
#}
#
#provider "kubernetes" {
#  host                   = data.aws_eks_cluster.cluster.endpoint
#  token                  = data.aws_eks_cluster_auth.cluster.token
#  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#}
#
#provider "aws" {
#  region       = "us-east-1"
#}