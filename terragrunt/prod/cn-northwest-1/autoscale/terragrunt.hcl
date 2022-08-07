include {
  path = find_in_parent_folders()
}

include "common" {
  path   = "${dirname(find_in_parent_folders())}/common/autoscale.hcl"
  expose = true
}

locals {
  ami_owner_id = "837727238323"
}

inputs = {
  ami_owner_id = local.ami_owner_id
}
