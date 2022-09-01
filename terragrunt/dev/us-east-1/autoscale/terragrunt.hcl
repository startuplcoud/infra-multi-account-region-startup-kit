include {
  path = find_in_parent_folders()
}

include "common" {
  path   = "${dirname(find_in_parent_folders())}/common/autoscale.hcl"
  expose = true
}

terraform {
  source = "../../../..//infra/module/autoscale"
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
  }
  before_hook "cloud-init" {
    commands     = ["apply", "plan"]
    execute      = ["cp", "${get_original_terragrunt_dir()}/config/init.yaml", "./config/init.yaml"]
    run_on_error = false
  }
}


locals {
  ami_owner_id = "099720109477"
}

inputs = {
  ami_owner_id = local.ami_owner_id
}
