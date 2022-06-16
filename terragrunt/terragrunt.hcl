locals {
  env_vars = yamldecode(file("${find_in_parent_folders("env.yaml")}"))
  aws_region = local.env_vars.locals.aws_region
  project = local.env_vars.locals.project
  account_id = yamldecode(file("${find_in_parent_folders("account.yaml")}"))
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = local.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${local.account_id}:role/terragrunt"
}
EOF
}

remote_state {
  backend  = "s3"
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
  local.region_vars.locals
  local.env_vars.locals
)