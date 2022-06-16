locals {
  env_vars     = yamldecode(file("${find_in_parent_folders("env.yaml")}"))
  account_vars = yamldecode(file("${find_in_parent_folders("account.yaml")}"))
  account_id   = local.account_vars["account_id"]
  role_name    = local.account_vars["role_name"]
  aws_region   = local.env_vars["aws_region"]
  project      = local.env_vars["project"]
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = local.aws_region
EOF
  #    assume_role {
  #    role_arn = "arn:aws:iam::${local.account_id}:role/terragrunt"
  #    session_name = "github-action"
  #}
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


