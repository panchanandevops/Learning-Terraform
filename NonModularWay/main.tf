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

# Create AWS key pair
resource "aws_key_pair" "example" {
  key_name   = "terraform-demo"  # Set a unique name for your key pair
  public_key = file("~/.ssh/id_rsa.pub")  # Specify the path to your public key file
}


# Define AWS VPC
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"  # Set the desired CIDR block for your VPC
}

# Establish AWS subnet with public IP
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id  # Reference the ID of the VPC created earlier
  cidr_block              = "10.0.0.0/24"  # Set the CIDR block for the subnet
  availability_zone       = "us-east-1a"  # Choose the desired availability zone
  map_public_ip_on_launch = true  # Enable automatic assignment of public IPs to instances
}

# Set up AWS internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id  # Attach the Internet Gateway to the previously created VPC
}

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

# Launch AWS EC2 instance
resource "aws_instance" "server" {
  ami                    = "ami-0261755bbcb8c4a84"  # Specify the desired Amazon Machine Image (AMI)
  instance_type          = "t2.micro"  # Choose the instance type
  key_name               = aws_key_pair.example.key_name  # Use the key pair created earlier
  vpc_security_group_ids = [aws_security_group.webSg.id]  # Attach the security group to the instance
  subnet_id              = aws_subnet.sub1.id  # Place the instance in the specified subnet

  connection {
    type        = "ssh"
    user        = "ubuntu"  # Replace with the appropriate username for your EC2 instance
    private_key = file("~/.ssh/id_rsa")  # Replace with the path to your private key
    host        = self.public_ip
  }

  # File provisioner to copy a file from local to the remote EC2 instance
  provisioner "file" {
    source      = "app.py"  # Replace with the path to your local file
    destination = "/home/ubuntu/app.py"  # Replace with the path on the remote instance
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo apt update -y",  # Update package lists (for Ubuntu)
      "sudo apt-get install -y python3-pip",  # Example package installation
      "cd /home/ubuntu",
      "sudo pip3 install flask",
      "sudo python3 app.py &",  # Start the application in the background
    ]
  }
}
