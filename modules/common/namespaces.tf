resource "kubernetes_namespace" "extra_namespace" {
  for_each = { for i, v in var.additional_namespaces : i => v }
  metadata {
    annotations = {
      name = each.value
    }
    name = each.value
  }
}
