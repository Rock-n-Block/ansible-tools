import_key:
	terraform -chdir=${module} import -var-file=../${vars} aws_key_pair.deployer deployer-key 

validate:
	terraform -chdir=${module} validate -var-file=../${vars}

plan:
	terraform -chdir=${module} plan -var-file=../${vars}

apply:
	terraform -chdir=${module} apply -var-file=../${vars}

show:
	terraform -chdir=${module} show -var-file=../${vars} 

destroy:
	terraform -chdir=${module} destroy -var-file=../${vars} 

workspace_select:
	terraform workspace select ${workspace} 

workspace_new:
	terraform workspace new ${workspace}

workspace_list:
	terraform workspace list