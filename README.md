# Ansible Tools


## Setup requirements

```bash
make setup
```

## Playbooks
Create DNS record via Cloudflare

```bash
make dns record=dev zone=rocknblock.io host=dev3 account=rnb
```

Deploy NGINX config

```bash
make nginx server_name=dev.rocknblock.io host=dev3
```

# hosts.yml 
Example config:
```
all:
  vars :
    cloudflare_tokens:
      rnb: 'insert-your-token-here'
  hosts:
    dev3 :
      ansible_host:
      ansible_user: backend
      configurations:
        devless.mywish.io:
          backend_path_remote: /home/backend/bridge_backend
          docker_expose_port: 9075
          nginx_port: 443
          letsencrypt_ssl: true
          http_redirect: true
          certbot_admin_email: example@gmail.com
        dev-ydr-bridge.rocknblock.io:
          backend_path_remote: /home/backend/bridge_backend_ydr
          docker_expose_port: 8777
          nginx_port: 443
          ssl_certificate: /etc/ssl/certs/rocknblock.io/fullchain.pem
          ssl_certificate_key: /etc/ssl/certs/rocknblock.io/privkey.pem
          letsencrypt_ssl : false
          http_redirect: true
```

# configurations
The following variables are supported:
* `nginx_port` **required** (Example: 443)

    NGINX internal port

 * `frontend_path_remote`  (Example: `/var/www/frontend`)

    Remote frontend static build directory

 * `backend_path_remote` (Example: `/var/www/backend`)

    Remote backend files directory, used to determine the Django static path

 * `letsencrypt_ssl` (Example: `yes`)

    Create Let's Encrypt Free SSL cerificate if `yes` and `nginx_port` is 443
