terraform {
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.6.3"
    }
  }
}

locals {
  cluster_name = format("atlassian-dc-%s-cluster", var.environment_name)
}

resource "aws_kms_key" "sops" {
  description = "${local.cluster_name} SOPS Key"
  tags        = var.resource_tags
}

data "sops_file" "secrets" {
  source_file = "secrets.yaml"
}

resource "local_file" "sops_yaml" {
  filename = "./.sops.yaml"
  content = yamlencode({
    creation_rules = [
      {
        kms = aws_kms_key.sops.arn
      }
    ]
  })
  file_permission = "0600"
}