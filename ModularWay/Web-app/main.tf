# Specify required provider and version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"  # Use a version constraint for compatibility
    }
  }
}

# Configure AWS provider with the region
provider "aws" {
  region = "us-east-1"
}