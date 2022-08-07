include {
  path = find_in_parent_folders()
}

include "common" {
  path   = "${dirname(find_in_parent_folders())}/common/rds.hcl"
  expose = true
}

locals {
  secrets     = yamldecode(sops_decrypt_file("${dirname(find_in_parent_folders())}/secrets.china.yaml"))["prod"]["cn-northwest-1"]
  db_password = local.secrets["db_password"]
}

inputs = {
  password = local.db_password
}