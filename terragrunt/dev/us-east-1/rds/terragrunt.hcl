include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../..//infra/module/rds"
}
locals {
  environment = "development"
}

include "common" {
  path   = "${dirname(find_in_parent_folders())}/common/rds.hcl"
  expose = true
}

inputs = {
  environment = local.environment
}