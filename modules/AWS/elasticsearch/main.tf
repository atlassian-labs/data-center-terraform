################################################################################
# Elasticsearch Instance
################################################################################

# Creating the Elasticsearch domain

resource "aws_elasticsearch_domain" "es" {
  domain_name           = local.cluster_name
  elasticsearch_version = local.es_version

  cluster_config {
    instance_type  = var.instance_type
    instance_count = var.instance_count
  }
  snapshot_options {
    automated_snapshot_start_hour = 23
  }
  vpc_options {
    subnet_ids = var.vpc_subnet_ids
  }
  ebs_options {
    ebs_enabled = var.ebs_volume_size > 0 ? true : false
    volume_size = var.ebs_volume_size
    volume_type = var.volume_type
  }
  tags = {
    Domain = "Elasticsearch"
  }
}

# Creating the AWS Elasticsearch domain policy

resource "aws_elasticsearch_domain_policy" "main" {
  domain_name     = aws_elasticsearch_domain.es.domain_name
  access_policies = <<POLICIES
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "${aws_elasticsearch_domain.es.arn}/*"
        }
    ]
}
POLICIES
}
