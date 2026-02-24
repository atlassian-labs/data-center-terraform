resource "kubectl_manifest" "session_affinity" {
  count      = var.use_gateway_api ? 1 : 0
  depends_on = [helm_release.bitbucket]

  yaml_body = <<-YAML
    apiVersion: gateway.envoyproxy.io/v1alpha1
    kind: BackendTrafficPolicy
    metadata:
      name: ${local.product_name}-session-affinity
      namespace: ${var.namespace}
    spec:
      targetRefs:
      - group: gateway.networking.k8s.io
        kind: HTTPRoute
        name: ${local.product_name}
      loadBalancer:
        type: ConsistentHash
        consistentHash:
          type: Cookie
          cookie:
            name: ATLROUTE_${upper(local.product_name)}
            ttl: 10h
  YAML
}
