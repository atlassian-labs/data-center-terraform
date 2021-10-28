# This file deals with where Terraform is keeping its state in AWS.
# Please note that this file will run by `pkg/script/start-dc-terraform.sh' and no need to run manually.
provider "aws" {
  region = var.region
}

module "tfstate-bucket" {
  source        = "../modules/AWS/s3"
  required_tags = var.resource_tags
  bucket_name   = local.bucket_name
}

module "tfstate-table" {
  source        = "../modules/AWS/dynamodb"
  required_tags = var.resource_tags
  dynamodb_name   = local.dynamodb_name
}
