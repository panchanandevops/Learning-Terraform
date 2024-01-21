# Define AWS VPC
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"  # Set the desired CIDR block for your VPC
}