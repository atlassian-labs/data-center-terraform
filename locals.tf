locals {
  // General settings
  region           = "us-east-1"
  cluster_name     = "dc-infrastructure"
  vpc_name         = "dc-infrastructure-vpc"

  // These two values will be used in the terraform/backend block in terraform-backend.tf file.
  bucket_name           = "dc-tf-statelock"
  dynamodb_name         = "dc_tf_statelock"

  // List of tags - this list will propagate among all resources
  required_tags = {
    business_unit  = "Engineering-Enterprise DC"
    service_name   = "dc-infrastructure"
    resource_owner = "nghazalibeiklar"
    git_repository = "github.com/atlassian-labs/data-center-terraform"
    Terraform      = "true"
  }
}
