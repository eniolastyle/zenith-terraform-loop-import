variable "domains" {
  type = list(object({
    name        = string
    ip_address  = string
    record_type = string
  }))
  default = {"barham.com" = {ip_address = "1.44.33.66", record_type = "A" }
            "AbuUmair.com" = {ip_address = "1.44.33.66", record_type = "A" }
            "AbMoney.com" = {ip_address = "1.44.33.66", record_type = "CNAME" }
  
  
  }
}

# resource "aws_route53_record" "domain_records" {
#   count = length(var.domains)

#   zone_id = aws_route53_zone.example_com.zone_id
#   name    = var.domains[count.index].name
#   type    = var.domains[count.index].record_type
#   ttl     = 300  # Modify this TTL as per your requirement

#   records = [var.domains[count.index].ip_address]
# }
variable "load_balancers" {
  type    = map(string)
  default = {
    "Barham.com" = "load-balancer-1-alias.aws.com"
    "AbuUmair.com" = "load-balancer-2-alias.aws.com"
    "AbMoney.com" = "load-balancer-3-alias.aws.com"
  }
}


module "instances" {
  source         = "./modules/instance"
  instance_types = ["t2.micro", "t2.medium", "t3.medium"]
  ami            = "ami-0aa2b7722dc1b5612"
  key_name       = "myec2"
  security_group = [aws_security_group.instance_sg.id]
  user_data      = <<-EOF
                #!/bin/bash
                sudo apt-get update
                sudo apt-get install nginx -y
                sudo systemctl start nginx
                sudo systemctl enable nginx
                EOF
}

resource "aws_s3_bucket" "eni_buck_buck" {
  bucket = "enibuckbuck"
}

resource "aws_security_group" "instance_sg" {
  name        = "my-instance-sg"
  description = "Security group for my instance"

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

variable "domain_records" {
  type = map(object({
    ip_address = string
    record_type = string
  }))
}

resource "aws_route53_record" "dns_records" {
  for_each = var.domain_records

  name    = each.key
  type    = each.value.record_type
  ttl     = 300
  records = [each.value.ip_address]
}