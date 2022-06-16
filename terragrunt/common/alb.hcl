dependency "vpc" {
  config_path = "..//vpc"
  mock_outputs = {
    public_subnet_ids             = ["ssss", "sssss"]
    vpc_id                        = "xxxxxx"
    default_vpc_security_group_id = "xxxxx"
  }
}

dependency "autoscale" {
  config_path = "..//autoscale"
  mock_outputs = {
    autoscaling_group_name = "xxxx"
  }
}

terraform {
  source = "../../../..//infra/module/alb"
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
  }
}

locals {
  port         = 80
  service_name = "nginx"
}

inputs = {
  port                   = local.port
  vpc_id                 = dependency.vpc.outputs.vpc_id
  load_balancer_subnets  = dependency.vpc.outputs.public_subnet_ids
  autoscaling_group_name = dependency.autoscale.outputs.autoscaling_group_name
}