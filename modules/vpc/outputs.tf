output "vpc_id" {
  value = module.aws_vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.aws_vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  value = module.aws_vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.aws_vpc.private_subnets
}
