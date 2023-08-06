resource "kubernetes_service_account" "aws_loadbalancer_controller" {
  metadata {
    name = local.lb_controller_service_account_name
    namespace = local.lb_controller_namespace
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_loadbalancer_controller.arn
    }
  }
}

# See: https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
resource "helm_release" "lb_controller" {
  name             = local.lb_controller_helm_chart_name
  namespace        = local.lb_controller_namespace
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  version          = local.lb_controller_helm_chart_version
  wait             = true

  values = [
    yamlencode({
      "clusterName" = var.cluster_name
      "serviceAccount" = {
        "create" = false
        "name" = local.lb_controller_service_account_name
      }
    })
  ]
}
