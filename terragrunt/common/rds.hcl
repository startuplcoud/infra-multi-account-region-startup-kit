terraform {
  source = "../../../..//infra/module/rds"
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
    vpc_cidr_block                = "10.1.0.0/16"
  }
}

locals {
  db_name    = "test"
  identifier = "test"
  username   = "postgres"
}

inputs = {
  vpc_id               = dependency.vpc.outputs.vpc_id
  security_cidr_blocks = dependency.vpc.outputs.vpc_cidr_block
  subnet_ids           = dependency.vpc.outputs.private_subnet_ids
  username             = local.username
  db_name              = local.db_name
  identifier           = local.identifier
}