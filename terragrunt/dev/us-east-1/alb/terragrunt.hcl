include {
  path = find_in_parent_folders()
}

locals {
  source = "../../../..//infra/module/alb"
}

include "common" {
  path   = "${dirname(find_in_parent_folders())}/common/alb.hcl"
  expose = true
}
