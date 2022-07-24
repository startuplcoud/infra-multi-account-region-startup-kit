include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../..//infra/env/kms_sops"
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
  }
}

inputs = {
  key_alias = "terragrunt-demo"
}