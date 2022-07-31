include {
  path = find_in_parent_folders()
}

include "common" {
  path   = "${dirname(find_in_parent_folders())}/common/vpc.hcl"
  expose = true
}
