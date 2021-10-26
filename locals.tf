locals {
  # General settings
  region           = "us-east-1"
  cluster_name     = "dc-infrastructure"
  # List of tags - this list will propagate among all resources
  required_tags = {
    business_unit  = "Engineering-Enterprise DC"
    service_name   = "dc-infrastructure"
    resource_owner = "nghazalibeiklar"
    git_repository = "github.com/atlassian-labs/data-center-terraform"
    Terraform      = "true"
  }

  # VPC settings
  vpc_name         = "dc-infrastructure-vpc"
  # At least two subnet CIDRs are required and will be calculated automatically based on `vpc_cidr`.
  vpc_cidr         = "10.0.0.0/16"

  environment_name = "test"
}
