## Table Of Content For This Project:
- [Terraform Deep Dive](#terraform-deep-dive)
  - [Aim Of The Project:](#aim-of-the-project)
    - [Prerequisites:](#prerequisites)
  - [AWS Architecture Diagram for Web Application](#aws-architecture-diagram-for-web-application)
  - [Configure the AWS provider](#configure-the-aws-provider)
  - [Create AWS key pair](#create-aws-key-pair)
  - [Define AWS VPC](#define-aws-vpc)
  - [Establish AWS subnet with public IP](#establish-aws-subnet-with-public-ip)
  - [Set up AWS internet gateway](#set-up-aws-internet-gateway)
  - [Create AWS route table](#create-aws-route-table)
  - [Associate route table with subnet](#associate-route-table-with-subnet)
  - [Configure AWS security group](#configure-aws-security-group)
  - [Launch AWS EC2 instance](#launch-aws-ec2-instance)
---


# Terraform Deep Dive


## Aim Of The Project:
**Create an EC2 instance within in a VPC and Public Subnet, then provision a flask app on it.we will use local backend and non-modular approach.**

### Prerequisites:
1. Configure AWS using AWS CLI
2. SSH keys
3. Terraform on you machine

## AWS Architecture Diagram for Web Application



<div style="text-align:center;">
  <img src="./IMG/architecture.png" alt="Image" style="width:90%;">
</div>


This architecture employs Terraform to build AWS infrastructure elements, including a **VPC**, **subnet**, **security groups**, and an **EC2 instance**.The EC2 instance is configured to host a **Flask web application**, accessible via **HTTP on port 80**, demonstrating seamless automation of deployment and networking configurations.

## Configure the AWS provider

You should specify the **version** as well as the AWS **region** you want the provider to operate in.

```
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
```

## Create AWS key pair

The following configuration creates an AWS ****key pair****. It requires an SSH ****public key**** and a ****key name****.

```
resource "aws_key_pair" "example" {
  key_name   = "terraform-demo"  # Set a unique name for your key pair
  public_key = file("~/.ssh/id_rsa.pub")  # Specify the path to your public key file
}
```

## Define AWS VPC

Create a **VPC** with a **CIDR block** of 10.0.0.0/16.

```
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"  # Set the desired CIDR block for your VPC
}
```

## Establish AWS subnet with public IP

Terraform code for creating an AWS **subnet** in VPC **"myvpc"** with CIDR **"10.0.0.0/24"** in availability zone **"us-east-1a"** and enabling public IPs on launch.

```
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id  # Reference the ID of the VPC created earlier
  cidr_block              = "10.0.0.0/24"  # Set the CIDR block for the subnet
  availability_zone       = "us-east-1a"  # Choose the desired availability zone
  map_public_ip_on_launch = true  # Enable automatic assignment of public IPs to instances
}
```

## Set up AWS internet gateway

This Terraform code creates an AWS **internet gateway** attached to the VPC named **"myvpc"**

```
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id  # Attach the Internet Gateway to the previously created VPC
}
```

## Create AWS route table

This Terraform code creates an AWS **route table** named **"RT"** associated with the VPC **"myvpc"** with a default route for all traffic pointing to the internet gateway named **"igw"**

```
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id  # Specify the VPC ID for the route table

  route {
    cidr_block = "0.0.0.0/0"  # Default route for all traffic
    gateway_id = aws_internet_gateway.igw.id  # Route traffic via the Internet Gateway
  }
}
```


## Associate route table with subnet

This Terraform code **associates** the route table **"RT"** with the subnet **"sub1"** using the association named **"rta1."**

```
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id  # Associate the route table with the specified subnet
  route_table_id = aws_route_table.RT.id  # Specify the ID of the route table
}
```

## Configure AWS security group

This Terraform code creates an AWS security group named **"webSg"** in the VPC **"myvpc"** allowing incoming **HTTP** traffic on **port 80** from within the VPC, incoming **SSH** traffic on **port 22** from anywhere, and allowing **all** outgoing traffic. It also includes a tag for **better identification** with the name **"Web-sg"**

```
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
```



## Launch AWS EC2 instance

This Terraform code provisions an AWS EC2 instance named **"server"** using the specified **AMI** ("ami-0261755bbcb8c4a84"), **instance type ("t2.micro")**, and **key pair** ("example"). It places the instance in the subnet **"sub1"** and associates it with the security group **"webSg."**

The code also establishes an SSH connection to the instance, copies a **local file ("app.py")** to the remote instance, and executes inline commands on the remote instance, including updating package lists, installing **Python3** and **Flask**, and starting the **"app.py"** application in the **background**.

```
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
```