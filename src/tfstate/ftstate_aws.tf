# This file deals with where Terraform is keeping its state in AWS.
provider "aws" {
  region = local.region
}

module "tfstate" {
  source        = "../modules/AWS/tfstate"
  required_tags = local.required_tags
  bucket_name   = local.bucket_name
  dynamodb_name = local.dynamodb_name
}
