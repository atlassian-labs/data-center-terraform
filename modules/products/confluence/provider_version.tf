terraform {
  required_providers {
    aws = {
      version = "~> 4.36"
    }
    kubernetes = {
      version = "~> 2.7"
    }
    helm = {
      version = "~> 2.4"
    }
    random = {
      source = "hashicorp/random"
      version = "3.6.1"
    }
  }
}