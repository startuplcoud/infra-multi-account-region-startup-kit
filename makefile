
format:
	cd infra && terraform fmt -check
	cd infra && terraform fmt -recursive
	cd terragrunt && terragrunt hclfmt

validate:
	pass

plan:
	pass

apply:
	pass

destroy:
	pass

plan-module:
	pass

apply-module:
	pass

destroy-module:
	pass

clean-cache:
	pass

