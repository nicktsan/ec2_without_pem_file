apply: plan
	terraform apply out.tfplan
plan: init
	terraform plan -var-file input.tfvars -out out.tfplan
init:
	terraform init