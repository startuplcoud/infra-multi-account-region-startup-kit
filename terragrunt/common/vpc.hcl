terraform {
  source = local.source
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
  }
}

locals {
  vpc_cidr    = "10.0.0.0/16"
  vpc_name    = "startupcloud"
  common_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  environment = local.common_vars["env"]
}

inputs = {
  vpc_cidr    = local.vpc_cidr
  environment = local.environment
  vpc_name    = local.vpc_name
}