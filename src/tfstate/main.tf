# This file deals with where Terraform is keeping its state in AWS.
# Please note that this file will run by `src/script/start-dc-terraform.sh' and no need to run manually.
provider "aws" {
  region = local.region
}

module "tfstate-bucket" {
  source        = "../modules/AWS/s3"
  required_tags = local.required_tags
  bucket_name   = local.bucket_name
}

module "tfstate-table" {
  source        = "../modules/AWS/dynamodb"
  required_tags = local.required_tags
  dynamodb_name   = local.dynamodb_name
}
