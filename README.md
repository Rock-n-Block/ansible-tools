# Ansible Tools


## Setup requirements

```bash
make setup
```

## Playbooks
Install deployment dependencies
```bash
make deps host=dev3
```

Setup firewall
```bash
make firewall host=dev3
```

Create DNS record via Cloudflare

```bash
make dns record=dev zone=rocknblock.io host=dev3 account=rnb
```

Deploy NGINX config

```bash
make nginx server_name=dev.rocknblock.io host=dev3
```

Sync directories
 
```bash
make sync-dir host=dev3 src=/home/user/nodes dest=/home/backend/nodes
```

Deploy frontend static files from archive 

(you should specify **builds_path** in **local.yml** to use this role!)
 
Parameters:
* src - archieve name
* dir (optional) - directiry from archieve content to deploy files from (often the archive contains a nested **build/** folder with the build content )


```bash
make sync-zip host=dev3 server_name=dev.rocknblock.io src=rnb_build_2.zip dir=build
```



# Configuration 
1. Create `hosts.yml` with hosts credentials:
```
all:
  hosts:
    dev3:
      ansible_host:
      ansible_user: backend
    dev4:
      ansible_host: 
      ansible_user: ubuntu
```
2. Create vars file `vars/<hostname from hosts.yml>.yml` for hosts where it is needed. Example: `vars/dev3.yml`:
```
nginx_confs:
  dev-project1.rocknblock.io:
    port: 443
    ssl_certificate: /etc/ssl/certs/rocknblock.io/fullchain.pem
    ssl_certificate_key: /etc/ssl/certs/rocknblock.io/privkey.pem
    http_redirect: true
    root_path: /var/www/project1_frontend/
    locations:
      /: 
        try_files: yes 
      /api/v1/:
        allow_cors: yes
        proxy_port: 8001
      /django-admin/:
        proxy_port: 8001
      /django-static/:
        alias: "/home/backend/project1_backend/static/"
      /media/:
        alias: "/home/backend/project1_backend/media/"
     
  dev-project2.rocknblock.io:
    port: 443
    ssl_certificate: /etc/ssl/certs/rocknblock.io/fullchain.pem
    ssl_certificate_key: /etc/ssl/certs/rocknblock.io/privkey.pem
    http_redirect: true
    root_path: /var/www/project2_frontend/
    locations:
      /: 
        try_files: yes 
      /api/v1/:
        allow_cors: yes
        proxy_port: 8002
      /django-admin/:
        proxy_port: 8002
      /django-static/:
        alias: "/home/backend/project2_backend/static/"
      /media/:
        alias: "/home/backend/project2_backend/media/"
      
```
3. Create `vars/local.yml` for general local settings. Example:
```
cloudflare_tokens:
  mywish: your_token_id_here
  rnb: your_token_id_here
builds_path: /home/ubuntu/builds
```


