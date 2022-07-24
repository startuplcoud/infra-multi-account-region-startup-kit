include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../..//infra/module/rds"
}

include "common" {
  path   = "${dirname(find_in_parent_folders())}/common/rds.hcl"
  expose = true
}

locals {
  secrets     = yamldecode(sops_decrypt_file("${dirname(find_in_parent_folders())}/secrets.global.yaml"))["prod"]
  db_password = local.secrets["db_password"]
}

inputs = {
  db_password = local.secrets["db_password"]
}