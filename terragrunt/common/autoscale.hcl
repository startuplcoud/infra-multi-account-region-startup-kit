dependency "vpc" {
  config_path = "${get_original_terragrunt_dir()}/..//vpc"
  mock_outputs = {
    private_subnet_ids            = ["ssss", "sssss"]
    vpc_id                        = "xxxxxx"
    default_vpc_security_group_id = "xxxxx"
  }
}

locals {
  port    = 80
  ssh_key = "startupcloud"
}

inputs = {
  ssh_key               = local.ssh_key
  port                  = local.port
  name                  = "startupcloud"
  vpc_id                = dependency.vpc.outputs.vpc_id
  private_subnets       = dependency.vpc.outputs.private_subnet_ids
  vpc_security_group_id = dependency.vpc.outputs.default_vpc_security_group_id
}
