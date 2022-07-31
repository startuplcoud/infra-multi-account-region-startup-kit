terraform {
  source = "../../../..//infra/module/autoscale"
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
  }
}

dependency "vpc" {
  config_path = "${get_original_terragrunt_dir()}/..//vpc"
  mock_outputs = {
    private_subnet_ids            = ["ssss", "sssss"]
    vpc_id                        = "xxxxxx"
    default_vpc_security_group_id = "xxxxx"
  }
}

dependencies {
  paths = [
    "${get_original_terragrunt_dir()}/..//vpc",
    "${get_original_terragrunt_dir()}/..//rds"
  ]
}


locals {
  port    = 80
  ssh_key = "startupcloud"
  name    = "startupcloud"
}

inputs = {
  ssh_key               = local.ssh_key
  instance_port         = local.port
  autoscaling_name      = local.name
  vpc_id                = dependency.vpc.outputs.vpc_id
  private_subnets       = dependency.vpc.outputs.private_subnet_ids
  vpc_security_group_id = dependency.vpc.outputs.default_vpc_security_group_id
}
