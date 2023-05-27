module "instances" {
  source           = "./modules/instance"
  instance_types   = ["t2.micro", "t2.medium", "t3.medium"]
  ami              = "ami-0aa2b7722dc1b5612"
  key_name         = "myec2"
  security_group   = [aws_security_group.instance_sg]
  user_data        = <<-EOF
                #!/bin/bash
                sudo apt-get update
                sudo apt-get install nginx -y
                sudo systemctl start nginx
                sudo systemctl enable nginx
                EOF
}

resource "aws_security_group" "instance_sg" {
  name        = "my-instance-sg"
  description = "Security group for my instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
