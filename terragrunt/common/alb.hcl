terraform {
  source = "../../../..//infra/module/alb"
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
  }
}

dependency "vpc" {
  config_path = "${get_original_terragrunt_dir()}/..//vpc"
  mock_outputs = {
    public_subnet_ids = ["ssss", "sssss"]
    vpc_id            = "xxxxxx"
  }
}

dependency "autoscale" {
  config_path = "${get_original_terragrunt_dir()}/..//autoscale"
  mock_outputs = {
    autoscaling_group_name = "xxxx"
  }
}

locals {
  target_port  = 80
  service_name = "nginx"
}

inputs = {
  service_name           = local.service_name
  target_port            = local.target_port
  vpc_id                 = dependency.vpc.outputs.vpc_id
  load_balancer_subnets  = dependency.vpc.outputs.public_subnet_ids
  autoscaling_group_name = dependency.autoscale.outputs.autoscaling_group_name
}