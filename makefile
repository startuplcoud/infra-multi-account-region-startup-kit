SHELL := /usr/bin/env bash
export AWS_PROFILE=$(aws_profile)
export TF_PLUGIN_CACHE_DIR=$(HOME)/.terraform.d/plugin-cache

init:
	brew install terragrunt terraform sops gnupg

format:
	cd infra && terraform fmt -check
	cd infra && terraform fmt -recursive
	cd terragrunt && terragrunt hclfmt

validate:
	cd terragrunt/$(directory) && terragrunt run-all validate
plan:
	cd terragrunt/$(directory) && terragrunt run-all plan
apply:
	cd terragrunt/$(directory) && terragrunt run-all apply
destroy:
	cd terragrunt/$(directory) && terragrunt run-all destroy

validate-module:
	cd terragrunt/$(directory) && terragrunt run-all plan --terragrunt-include-dir $(module)

plan-module:
	cd terragrunt/$(directory) && terragrunt run-all plan --terragrunt-include-dir $(module)

apply-module:
	cd terragrunt/$(directory) && terragrunt run-all apply --terragrunt-include-dir $(module)

destroy-module:
	cd terragrunt/$(directory) && terragrunt run-all destroy --terragrunt-working-dir $(module)

unlock:
	cd terragrunt/$(directory) && terragrunt force-unlock $(lock_id)

clean-cache:
	find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;

