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

# Include the module with specific values
module "web_app" {
  source = "./web-app-module"

  instance_type          = "t2.micro"
  ami_id                 = "ami-0261755bbcb8c4a84"  # Replace with your desired AMI ID
  subnet_cidr_block      = "10.0.0.0/24"  # Replace with your desired subnet CIDR block
  ssh_key_path           = "~/.ssh/id_rsa"  # Replace with your desired path to SSH private key file
  app_source_path        = "app.py"  # Replace with your desired path to the local application source file
  vpc_cidr_block         = "10.0.0.0/16"
  availability_zone       = "us-east-1a"
  ingress_http_cidr_blocks = ["0.0.0.0/0"]
  ingress_ssh_cidr_blocks  = ["0.0.0.0/0"]
  egress_cidr_blocks      = ["0.0.0.0/0"]
}
