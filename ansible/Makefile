hosts_path := hosts.yml
ansible_cfg := ANSIBLE_CONFIG=$(shell pwd)/ansible.cfg

setup-roles:
	$(ansible_cfg) ansible-galaxy role install -r requirements.yml --force

setup-collections:
	$(ansible_cfg) ansible-galaxy collection install -r requirements.yml --force

setup: setup-roles setup-collections

nginx:
	test $(host)
	test $(server_name)
	$(ansible_cfg) ansible-playbook -i=$(hosts_path) -l $(host) playbooks/nginx.yml --extra-vars "server_name=$(server_name)"

dns:
	test $(host)
	test $(record)
	test $(zone)
	test $(account)
	$(ansible_cfg) ansible-playbook -i=$(hosts_path) playbooks/dns.yml --extra-vars "record=$(record) zone=$(zone) host=$(host) account=$(account)"

deps:
	test $(host)
	$(ansible_cfg) ansible-playbook -i=$(hosts_path) -l $(host) playbooks/deps.yml

firewall:
	test $(host)
	$(ansible_cfg) ansible-playbook -i=$(hosts_path) -l $(host) playbooks/firewall.yml

sync-zip:
	test $(host)
	test $(src)
	test $(server_name)
	$(ansible_cfg) ansible-playbook -i=$(hosts_path) -l $(host) playbooks/sync_zip.yml --extra-vars "src=$(src) server_name=$(server_name) dir=$(dir)"

sync-dir:
	test $(host)
	test $(src)
	test $(dest)
	$(ansible_cfg) ansible-playbook -i=$(hosts_path) -l $(host) playbooks/sync_dir.yml --extra-vars "src=$(src) dest=$(dest)"

mount-second-ebs:
	test $(host)
	$(ansible_cfg) ansible-playbook -i=$(hosts_path) -l $(host) playbooks/mount_second_ebs.yml

launch-geth:
	test $(host)
	$(ansible_cfg) ansible-playbook -i=$(hosts_path) -l $(host) playbooks/launch_geth.yml