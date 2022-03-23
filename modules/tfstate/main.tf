# This file deals with where Terraform is keeping its state in AWS.
# Please note that this file will run by `install.sh' and no need to run manually.
terraform {

  required_providers {
    aws = {
      version = "~> 3.74"
    }
  }
}

provider "aws" {
  region = var.region
}

module "tfstate-bucket" {
  source        = "../AWS/s3"
  required_tags = var.resource_tags
  bucket_name   = local.bucket_name
}

module "tfstate-table" {
  source        = "../AWS/dynamodb"
  required_tags = var.resource_tags
  dynamodb_name = local.dynamodb_name
}
