include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../..//infra/module/rds"
}

locals {

}

include "common" {
  path   = "${dirname(find_in_parent_folders())}/common/rds.hcl"
  expose = true
}
locals {
  environment = "production"
  secrets     = yamldecode(sops_decrypt_file("${dirname(find_in_parent_folders())}/secrets.global.yaml"))["prod"]
  db_password = local.secrets["db_password"]
}

inputs = {
  environment = local.environment
  db_password = local.secrets["db_password"]
}