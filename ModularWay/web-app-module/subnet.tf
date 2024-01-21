# Establish AWS subnet with public IP
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id  # Reference the ID of the VPC created earlier
  cidr_block              = "10.0.0.0/24"  # Set the CIDR block for the subnet
  availability_zone       = "us-east-1a"  # Choose the desired availability zone
  map_public_ip_on_launch = true  # Enable automatic assignment of public IPs to instances
}