# terraform.tfvars

instance_type          = "t2.micro"
ami_id                 = "ami-0261755bbcb8c4a84"
subnet_cidr_block      = "10.0.0.0/24"
ssh_key_path           = "~/.ssh/id_rsa"
app_source_path        = "app.py"
vpc_cidr_block         = "10.0.0.0/16"
availability_zone       = "us-east-1a"
ingress_http_cidr_blocks = ["0.0.0.0/0"]
ingress_ssh_cidr_blocks  = ["0.0.0.0/0"]
egress_cidr_blocks      = ["0.0.0.0/0"]
