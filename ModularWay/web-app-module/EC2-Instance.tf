# EC2-Instance.tf

# Launch AWS EC2 instance
resource "aws_instance" "server" {
  ami                    = var.ami_id  # Specify the desired Amazon Machine Image (AMI) using the variable
  instance_type          = var.instance_type  # Choose the instance type using the variable
  key_name               = aws_key_pair.example.key_name  # Use the key pair created earlier
  vpc_security_group_ids = [aws_security_group.webSg.id]  # Attach the security group to the instance
  subnet_id              = aws_subnet.sub1.id  # Place the instance in the specified subnet

  connection {
    type        = "ssh"
    user        = "ubuntu"  # Replace with the appropriate username for your EC2 instance
    private_key = file(var.ssh_key_path)  # Replace with the path to your private key using the variable
    host        = self.public_ip
  }

  # File provisioner to copy a file from local to the remote EC2 instance
  provisioner "file" {
    source      = var.app_source_path  # Replace with the path to your local file using the variable
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
