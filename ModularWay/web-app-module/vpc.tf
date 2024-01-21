# vpc.tf

# Define AWS VPC
resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr_block  # Use the desired CIDR block for your VPC
}
