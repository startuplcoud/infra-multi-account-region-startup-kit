terraform {
  source = "../../../..//infra/module/vpc"
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
  }
}

locals {
  vpc_cidr = "10.0.0.0/16"
  vpc_name = "startupcloud"
}

inputs = {
  vpc_cidr = local.vpc_cidr
  vpc_name = local.vpc_name
}