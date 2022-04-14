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

output "kubernetes_provider_config" {
  value = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
  sensitive = true
}

output "cluster_security_group" {
  value = module.eks.cluster_primary_security_group_id
}

output "cluster_asg_name" {
  value = local.cluster_asg_name
}

output "max_cluster_size" {
  value = module.eks.node_groups["appNodes"]["scaling_config"][0]["max_size"]
}

output "min_cluster_size" {
  value = module.eks.node_groups["appNodes"]["scaling_config"][0]["min_size"]
}

output "availability_zone" {
  # TODO we are assuming the used availability zone is always aws-region"a"
  # Fetching this value dynamically from ASG subnet brings additional challenges
  value = "${var.region}a"
}