variable "instance_types" {
  type    = list(string)
  default = ["t2.micro", "t3.medium", "t2.midium"]
}

variable "ami" {
  type = string
}

variable "key_name" {
  type = string
}

variable "security_group" {
  type = list(string)
}

variable "user_data" {}


resource "aws_instance" "servers" {
  for_each 		 = toset(var.instance_types)
  ami                    = var.ami
  instance_type          = each.value
  key_name               = var.key_name
  vpc_security_group_ids = var.security_group
  user_data              = var.user_data

  tags = {
    "Name" = "${each.value}-server"
  }
}

output "public_ips" {
  value = [for instance in aws_instance.servers : instance.public_ip]
}

output "instance_ids" {
  value = [for instance in aws_instance.servers : instance.id]
}
