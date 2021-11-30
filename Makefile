hosts_path := hosts.yml

nginx:
	test $(host)
	test $(server_name)
	$(ansible_cfg) ansible-playbook -i=$(hosts_path) -l $(host) tasks/nginx.yml --extra-vars "server_name=$(server_name)"

dns:
	test $(host)
	test $(server_name)
	$(ansible_cfg) ansible-playbook -i=$(hosts_path) tasks/dns.yml --extra-vars "server_name=$(server_name) host=$(host)"