include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../..//infra/module/autoscale"
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
  }
}

include "common" {
  path   = "${dirname(find_in_parent_folders())}/common/autoscale.hcl"
  expose = true
}

locals {
  ami_owner_id = "099720109477"
}

inputs = {
  ami_owner_id = local.ami_owner_id
}
