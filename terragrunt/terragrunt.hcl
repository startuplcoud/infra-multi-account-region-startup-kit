locals {
  env_vars   = yamldecode(file("${find_in_parent_folders("env.yaml")}"))
  aws_region = local.env_vars["aws_region"]
  project    = local.env_vars["project"]
  account_id = local.env_vars["account_id"]
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  allowed_account_ids  = [ "${local.account_id}" ]
}
EOF
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "${local.project}-terraform-state-${local.aws_region}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "${local.project}-terraform-lock-table"
  }
}

inputs = merge(
  local.env_vars
)


