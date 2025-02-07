terraform {
  backend "s3" {
    bucket         = "juls-devops-training-nyar"
    key            = "terraform/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

# Lookup existing VPC by ID
data "aws_vpc" "existing_vpc" {
  id = "vpc-0ac15a8ab99f47d9e"
}

# Lookup existing Security Group inside the VPC
data "aws_security_group" "existing_sg" {
  vpc_id = data.aws_vpc.existing_vpc.id
  name   = "manila-ops-devops-training-internal-and-secure-public"
}

# Lookup an existing subnet inside the VPC
data "aws_subnet" "existing_subnet" {
  vpc_id = data.aws_vpc.existing_vpc.id
}

resource "aws_instance" "flask_app" {
  ami                    = "ami-085ad6ae776d8f09c"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.aws_security_group.existing_sg.id] # Dynamically fetch SG ID
  subnet_id              = data.aws_subnet.existing_subnet.id       # Automatically get a subnet

  tags = {
    Name = "flask-app-instance-juls"
  }
}

output "ec2_public_ip" {
  value = aws_instance.flask_app.public_ip
}
