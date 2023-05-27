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


variable "domains" {
  type    = list(string)
  default = ["AbuUmair.com", "Barham.com", "AbMoney.org"]  # Add your list of domain names here
}
variable "load_balancers" {
  type    = map(string)
  default = {
    "example1.com" = "load-balancer-1-alias.aws.com"
    "example2.com" = "load-balancer-2-alias.aws.com"
    "example3.com" = "load-balancer-3-alias.aws.com"
  }
}


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
