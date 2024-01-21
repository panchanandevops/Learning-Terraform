# Configure AWS security group
resource "aws_security_group" "webSg" {
  name   = "web"  # Set the name for the security group
  vpc_id = aws_vpc.myvpc.id  # Specify the VPC ID where the security group will be created

  ingress {
    description = "HTTP from VPC"  # Allow incoming HTTP traffic from within the VPC
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"  # Allow incoming SSH traffic from anywhere
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outgoing traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"  # Set a tag for better identification
  }
}