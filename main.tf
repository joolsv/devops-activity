provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "flask_key" {
  key_name   = "jv-key"
  public_key = file("/root/.ssh/jv-key.pub") # Ensure this file exists
}

resource "aws_instance" "flask_app" {
  ami           = "ami-085ad6ae776d8f09c"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.flask_key.key_name # Ensure SSH key is used

  tags = {
    Name = "flask-app-instance-juls"
  }

  # Connection block required for provisioners
  connection {
    type        = "ssh"
    user        = "ec2-user" # Default Amazon Linux user
    private_key = file("/root/.ssh/jv-key") # Ensure this private key exists
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "../ansible"
    destination = "/home/ec2-user/"
  }
}

output "ec2_public_ip" {
  value = aws_instance.flask_app.public_ip
}
