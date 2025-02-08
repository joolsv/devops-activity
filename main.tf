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

data "aws_vpc" "existing_vpc" {
  id = "vpc-0ac15a8ab99f47d9e"
}

data "aws_security_group" "existing_sg" {
  vpc_id = data.aws_vpc.existing_vpc.id
  name   = "manila-ops-devops-training-internal-and-secure-public"
}

data "aws_subnet" "us_east_1b_subnet" {
  vpc_id            = data.aws_vpc.existing_vpc.id
  availability_zone = "us-east-1b"
}

resource "aws_s3_bucket" "ssm_files" {
  bucket = "juls-devops-training-files"
  force_destroy = true
}

resource "aws_s3_object" "inventory_ini" {
  bucket = aws_s3_bucket.ssm_files.id
  key    = "inventory.ini"
  source = "inventory.ini"
  acl    = "private"
}

resource "aws_s3_object" "deploy_yml" {
  bucket = aws_s3_bucket.ssm_files.id
  key    = "deploy.yml"
  source = "deploy.yml"
  acl    = "private"
}

resource "aws_instance" "flask_app" {
  ami                    = "ami-085ad6ae776d8f09c"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]
  subnet_id              = data.aws_subnet.us_east_1b_subnet.id
  iam_instance_profile   = "FT-EC2-Role"

  tags = {
    Name = "flask-app-instance-juls"
  }

  user_data = <<EOF
#!/bin/bash
set -e

if ! command -v aws &> /dev/null; then
    dnf update -y && dnf install aws-cli -y
fi

aws s3 cp s3://${aws_s3_bucket.ssm_files.id}/inventory.ini /home/ec2-user/inventory.ini
aws s3 cp s3://${aws_s3_bucket.ssm_files.id}/deploy.yml /home/ec2-user/deploy.yml

chmod 644 /home/ec2-user/inventory.ini /home/ec2-user/deploy.yml
EOF
}

output "ec2_public_ip" {
  value = aws_instance.flask_app.public_ip
}
