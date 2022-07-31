include {
  path = find_in_parent_folders()
}

locals {
  secrets     = yamldecode(sops_decrypt_file("${dirname(find_in_parent_folders())}/secrets.global.yaml"))["stage"]["ap-southeast-1"]
  db_password = local.secrets["db_password"]
}

include "common" {
  path   = "${dirname(find_in_parent_folders())}/common/rds.hcl"
  expose = true
}

inputs = {
  password = local.db_password
}