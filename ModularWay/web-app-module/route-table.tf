# Create AWS route table
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id  # Specify the VPC ID for the route table

  route {
    cidr_block = "0.0.0.0/0"  # Default route for all traffic
    gateway_id = aws_internet_gateway.igw.id  # Route traffic via the Internet Gateway
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id  # Associate the route table with the specified subnet
  route_table_id = aws_route_table.RT.id  # Specify the ID of the route table
}