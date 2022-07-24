locals {
  vpc_cidr = "10.0.0.0/16"
  vpc_name = "startupcloud"
}

inputs = {
  vpc_cidr = local.vpc_cidr
  vpc_name = local.vpc_name
}