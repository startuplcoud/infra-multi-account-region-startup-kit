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
    "arn:aws-cn:iam::527109613237:role/terragrunt"
  ]
}

inputs = {
  multi_region  = false
  key_alias     = "terragrunt-startup"
  role_arn_list = local.role_arn_list
}
