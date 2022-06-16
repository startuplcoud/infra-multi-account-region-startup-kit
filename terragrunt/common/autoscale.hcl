

dependency "vpc" {
  config_path = "..//vpc"
  mock_outputs = {
    private_subnet_ids            = ["ssss", "sssss"]
    vpc_id                        = "xxxxxx"
    default_vpc_security_group_id = "xxxxx"
  }
}

locals {
  instance_type = ""
  port          = 80
  ssh_key       = "startupcloud"
}

inputs = {
  vpc_id                = dependency.vpc.outputs.vpc_id
  instance_type         = local.instance_type
  private_subnets       = dependency.vpc.outputs.private_subnet_ids
  vpc_security_group_id = dependency.vpc.outputs.default_vpc_security_group_id
}
