include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../..//infra/module/rds"
}

locals {
  environment = "development"
  secrets     = yamldecode(sops_decrypt_file("${dirname(find_in_parent_folders())}/secrets.global.yaml"))["dev"]
  db_password = local.secrets["db_password"]
}

include "common" {
  path   = "${dirname(find_in_parent_folders())}/common/rds.hcl"
  expose = true
}

inputs = {
  environment = local.environment
  password    = local.db_password
}