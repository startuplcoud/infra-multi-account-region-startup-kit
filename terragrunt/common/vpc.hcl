


locals {
  vpc_cidr    = "10.0.0.0/16"
  vpc_name    = "startupcloud"
  common_vars = yamldecode(file("${find_in_parent_folders("env.yaml")}"))
  environment = local.common_vars["environment"]
}

inputs = {
  vpc_cidr    = local.vpc_cidr
  environment = local.environment
  vpc_name    = local.vpc_name
}