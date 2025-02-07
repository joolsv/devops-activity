provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "flask_app" {
  ami           = "ami-085ad6ae776d8f09c"
  instance_type = "t2.micro"
  key_name      = "jv-key"

  tags = {
    Name = "flask-app-instance-juls"
  }

  # Connection block required for provisioners
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/jv-key")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "../ansible"
    destination = "/home/ec2-user/ansible"
  }
}

output "ec2_public_ip" {
  value = aws_instance.flask_app.public_ip
}

