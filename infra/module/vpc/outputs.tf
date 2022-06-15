output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}
output "default_vpc_security_group_id" {
  value = module.vpc.default_vpc_security_group_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

