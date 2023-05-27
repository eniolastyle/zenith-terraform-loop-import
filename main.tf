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





resource "aws_route53_zone" "domains" {
  for_each = toset(var.domains)

  name = each.value
}

resource "aws_route53_record" "domain_records" {
  for_each = aws_route53_zone.domains

  zone_id = aws_route53_zone.domains[each.key].zone_id
  name    = "www.${each.key}"  # This prepends "www." to each domain name
  type    = "A"
  ttl     = 300  # This parameter determines the Time to Live (TTL) for the DNS record, which specifies how long the record should be cached

  alias {
    name                   = var.load_balancers[each.key]
    zone_id                = "your-load-balancer-zone-id"  # Replace with the appropriate load balancer's zone ID
    evaluate_target_health = true  # Set to true if you want health checks on the target
  }
}