# ExternalDNS can be disabled by setting 'create_external_dns' to 'false.
# It uses the DNS name of the ingress to create additional entries.
# See https://github.com/kubernetes-sigs/external-dns

module "external_dns_iam_role" {
  source       = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version      = "4.13.2"
  create_role  = var.create_external_dns
  role_name    = "${var.cluster_name}-external-dns"
  provider_url = replace(var.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns = [
    var.create_external_dns ? aws_iam_policy.external_dns[0].arn : null
  ]
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:${local.external_dns_namespace}:${local.external_dns_name}"
  ]
}

resource "aws_iam_policy" "external_dns" {
  count       = var.create_external_dns ? 1 : 0
  name        = "${var.cluster_name}_ExternalDNS"
  description = "External DNS policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.external_dns[count.index].json
}

data "aws_iam_policy_document" "external_dns" {
  count = var.create_external_dns ? 1 : 0
  statement {
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets"
    ]

    resources = [
      "arn:aws:route53:::hostedzone/${var.zone_id}"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]

    resources = [
      "*"
    ]
  }
}

resource "kubernetes_namespace" "external_dns" {
  count = var.create_external_dns ? 1 : 0
  metadata {
    name = "external-dns"
  }
}

resource "helm_release" "external_dns" {
  count      = var.create_external_dns ? 1 : 0
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  name       = local.external_dns_name
  namespace  = kubernetes_namespace.external_dns[count.index].metadata[0].name
  version    = local.external_dns_version

  values = [yamlencode({
    image = {
      repository = "bitnamilegacy/external-dns"
    }
    provider      = "aws"
    domainFilters = [var.ingress_domain]
    policy        = "sync"
    txtOwnerId    = "${var.cluster_name}-external-dns"
    serviceAccount = {
      annotations = {
        "eks.amazonaws.com/role-arn" : module.external_dns_iam_role.iam_role_arn
      }
    }
  })]
}
