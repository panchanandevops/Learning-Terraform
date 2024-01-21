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

# Include the module with specific values from the terraform.tfvars file
module "web_app" {
  source = "./web-app-module"

  # Use the variables from the terraform.tfvars file
  instance_type          = var.instance_type
  ami_id                 = var.ami_id
  subnet_cidr_block      = var.subnet_cidr_block
  ssh_key_path           = var.ssh_key_path
  app_source_path        = var.app_source_path
  vpc_cidr_block         = var.vpc_cidr_block
  availability_zone       = var.availability_zone
  ingress_http_cidr_blocks = var.ingress_http_cidr_blocks
  ingress_ssh_cidr_blocks  = var.ingress_ssh_cidr_blocks
  egress_cidr_blocks      = var.egress_cidr_blocks
}
