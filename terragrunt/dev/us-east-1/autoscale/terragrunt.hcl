include {
  path = find_in_parent_folders()
}

locals {
  source = "../../../..//infra/module/autoscale"
}

include "common" {
  path   = "${dirname(find_in_parent_folders())}/common/autoscale.hcl"
  expose = true
}
