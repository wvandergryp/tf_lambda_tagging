# Configure the AWS provider
provider "aws" {
    region  = var.region  # The AWS region where resources will be created
    profile = var.profile  # The AWS CLI profile to use
}

# Specify the required providers and their versions
terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"  # The source of the archive provider
      version = "~> 2.0"  # The version of the archive provider
    }
  }
}