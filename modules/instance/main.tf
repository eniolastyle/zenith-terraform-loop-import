variable "instance_types" {
  type    = list(string)
  default = ["t2.micro", "t3.medium", t2.midium"]
}

variable "ami" {
  type    = string
}

variable "key_name" {
  type    = string
}

variable "security_group" {
  type    = list(string)
}

variable "user_data" {}


resource "aws_instance" "servers" {
  ami                    = var.ami
  instance_type          = toset([for i in var.instance_types : i])
  key_name               = var.key_name
  vpc_security_group_ids = var.security_group
  user_data              = var.user_data

  tags = {
    "Name" = "${[for i in var.instance_types : i]}-server"
  }
}

output "public_ips" {
  value = aws_instance.servers[*].public_ip
}

output "instance_ids" {
  value = aws_instance.servers[*].id
}
