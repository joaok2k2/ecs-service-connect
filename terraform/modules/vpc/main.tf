module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.cidr_vpc
  azs  = ["${var.region}a", "${var.region}b", "${var.region}c"]

  public_subnets = var.pub_sub
  private_subnets = var.private_sub

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "main" {
  name   = "SG-ECS-SERVICE-CONNECT"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allows  inbound"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

