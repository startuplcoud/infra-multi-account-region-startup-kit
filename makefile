format:
	cd infra && terraform fmt -check
	cd infra && terraform fmt -recursive
	cd terragrunt && terragrunt hclfmt
validate:
	cd terragrunt && terragrunt run-all validate
plan:
	cd terragrunt && terragrunt run-all plan
apply:
	cd terragrunt && terragrunt run-all apply
destroy:
	cd terragrunt && terragrunt run-all destroy
plan-module:
	cd terragrunt && terragrunt run-all plan --terragrunt-include-dir $(directory)

apply-module:
	cd terragrunt && terragrunt run-all apply --terragrunt-include-dir $(directory)

destroy-module:
	cd terragrunt && terragrunt run-all destroy --terragrunt-include-dir $(directory)
clean-cache:
	find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;

