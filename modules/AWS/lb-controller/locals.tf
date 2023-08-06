locals {
  lb_controller_helm_chart_name      = "aws-load-balancer-controller"
  lb_controller_helm_chart_version   = "1.5.5"
  lb_controller_namespace            = "kube-system"
  lb_controller_service_account_name = "aws-load-balancer-controller"
}
