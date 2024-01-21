# Create AWS key pair
resource "aws_key_pair" "example" {
  key_name   = "terraform-demo"  # Set a unique name for your key pair
  public_key = file("~/.ssh/id_rsa.pub")  # Specify the path to your public key file
}