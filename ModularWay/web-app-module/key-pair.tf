# key-pair.tf

# Create AWS key pair
resource "aws_key_pair" "example" {
  key_name   = "terraform-demo"  # Set a unique name for your key pair
  public_key = file(var.ssh_key_path)  # Specify the path to your public key file using the variable
}
