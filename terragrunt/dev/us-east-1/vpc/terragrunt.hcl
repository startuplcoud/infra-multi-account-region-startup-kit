include {
  path = find_in_parent_folders()
}

locals {
  source = "../../../..//infra/module/vpc"
}

include "common" {
  path   = "${dirname(find_in_parent_folders())}/common/vpc.hcl"
  expose = true
}
