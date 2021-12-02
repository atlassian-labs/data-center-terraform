provider "aws" {
  region = var.region
  default_tags {
    tags = var.resource_tags
  }
}