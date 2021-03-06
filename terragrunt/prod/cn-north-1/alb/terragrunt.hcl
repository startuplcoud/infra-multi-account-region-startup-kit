include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../..//infra/module/alb"

  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
  }
}

include "common" {
  path   = "${dirname(find_in_parent_folders())}/common/alb.hcl"
  expose = true
}
