dependency "vpc" {
  config_path = "${get_original_terragrunt_dir()}/..//vpc"
  mock_outputs = {
    public_subnet_ids             = ["ssss", "sssss"]
    vpc_id                        = "xxxxxx"
    default_vpc_security_group_id = "xxxxx"
  }
}

dependency "autoscale" {
  config_path = "${get_original_terragrunt_dir()}/..//autoscale"
  mock_outputs = {
    autoscaling_group_name = "xxxx"
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