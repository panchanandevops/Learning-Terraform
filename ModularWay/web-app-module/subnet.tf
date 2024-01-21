# subnet.tf

# Establish AWS subnet with public IP
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id  # Reference the ID of the VPC created earlier
  cidr_block              = var.subnet_cidr_block  # Use the subnet CIDR block variable
  availability_zone       = var.availability_zone  # Use the desired availability zone
  map_public_ip_on_launch = true  # Enable automatic assignment of public IPs to instances
}
