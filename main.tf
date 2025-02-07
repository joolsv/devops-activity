provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "flask_app" {
  ami           = "ami-085ad6ae776d8f09c"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.flask_key.key_name # Ensure SSH key is used

  tags = {
    Name = "flask-app-instance-juls"
  }
}

output "ec2_public_ip" {
  value = aws_instance.flask_app.public_ip
}
