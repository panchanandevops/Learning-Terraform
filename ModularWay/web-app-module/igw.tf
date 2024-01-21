# Set up AWS internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id  # Attach the Internet Gateway to the previously created VPC
}