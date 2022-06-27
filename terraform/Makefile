import_key:
	terraform -chdir=${module} import -var-file=../${vars} aws_key_pair.deployer deployer-key 

init:
	terraform -chdir=${module} init

validate:
	terraform -chdir=${module} validate 

plan:
	terraform -chdir=${module} plan -var-file=../${vars}

apply:
	terraform -chdir=${module} apply -var-file=../${vars}

show:
	terraform -chdir=${module} show 

destroy:
	terraform -chdir=${module} destroy -var-file=../${vars} 

workspace_select:
	terraform -chdir=${module} workspace select ${workspace} 

workspace_new:
	terraform -chdir=${module} workspace new ${workspace}

workspace_list:
	terraform -chdir=${module} workspace list