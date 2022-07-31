include {
  path = find_in_parent_folders()
}

include "common" {
  path   = "${dirname(find_in_parent_folders())}/common/vpc.hcl"
  expose = true
}

locals {
  vpc_cidr = "12.0.0.0/16"
  vpc_name = "startupcloud-stage"
}

inputs = {
  vpc_cidr = local.vpc_cidr
  vpc_name = local.vpc_name
}