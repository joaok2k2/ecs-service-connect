output "sub-public" {
  value = module.vpc.public_subnets
}


output "sub-private" {
  value = module.vpc.private_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "sg-service" {
  value = aws_security_group.main.id
}

