include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../..//infra/global-config/kms_sops"
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
  }
}

locals {
  role_arn_list = [
    "arn:aws:iam::594962198840:role/terragrunt"
  ]
  user_arn_list = [
    "arn:aws:iam::733051034790:user/admin"
  ]
}

inputs = {
  key_alias     = "terragrunt-startup"
  role_arn_list = local.role_arn_list
  user_arn_list = local.user_arn_list
}