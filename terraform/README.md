# Terraform Tools  


## Overview

This repo contains Terraform configurations for automated tasks

## Prerequesites

* Terraform
* AWS CLI
* Ansible

## Basic usage

1. Copy `vars-example.tfvars` to `terraform.tfvars` or other `some-vars-file.tfvars` file
```bash
cp vars-example.tfvars name_of_setup.tfvars
```
2. Adjust `.tfvars` file according to your needs
3. (optional) Create new workspace for state (commands listed in [Workspace comands](###workspace-commands) section)
3. Choose module for interaction (listed in [Avaiable modules](##avalable-modules) section), you must supply name of module to `module=` variable
4. Run appropriate commands (listed in [Deployment commands](###deployment-commandss) section) with your `.tfvars` file, passing his name to `vars=` variable
5. After execution of module, Terraform will create file `tfgenhosts-<server_name>-<aws_id>.yml` in module directory. You can use contents of this file to add new instance in local Anisble hosts.yml file

---

### Deployment commands

`vars_file` - file of Terraform variables (must be places in this directory)
`name_of_module` - name of module to use (listed below)

Validate configuration
```bash
make validate module=<name_of_module>
```

Show changes which will be applied 
```bash
make plan module=<name_of_module> vars=<vars_file>
```

Apply changes to servers
```bash
make apply module=<name_of_module> vars=<vars_file>
```

Show current applied configuration
```bash
make show module=<name_of_module>
```

Remove configuration from servers
```bash
make destroy module=<name_of_module> vars=<vars_file>
```

### Workspace commands

Workspaces are needed to operate current Terraform state

**Notice:** workspaces for each submodule stored separately in module folder. 

List workspaces
```bash
make workspace_list module=<name_of_module>
```

Change workspace
```bash
make workspace_select module=<name_of_module> workspace=<name_of_workspace>
```

Create new workspace
```bash
make workspace_new module=<name_of_module> workspace=<name_of_workspace>
```

---

## Avaiable modules

- `ec2-base` - module for deploying customisable EC2 instances
- `ec2-node-eth` - module for deploying customisable EC2 instances that is specialized on running Go-Ethereum nodes


### Terraform ec2-base module description

#### Supported features
- EC2 deployment
- Security Group creation
- SSH Key import
- Tag assigment on instances/security groups/block devices

#### Customizable parameters:
- AWS Provider settings (login by Acces & Secret keys or AWS CLI profile)
- SSH key to setup
- EC2 AMI (currently raw AMI ID supported)
- EC2 Storage type
- EC2 Instance type
- Secutiry Group exposed ports
- Tags (Name, Org) are currently supported

#### Note on SSH connections

By default, password-protected (encrypted) private ssh keys are not supported in Terraform
But, if you use such key and some sort of ssh agent, you can set variable `ssh_agent_support = true` to utilize ssh agent

#### Importing existing keys

If you changing state, but SSH key was already created on AWS, Terraform will create error.
In order to make it work with already imported key, you need to refresh your local state with key that exist on AWS:
```bash
make import_key module=<namme_of_module> aws_key_pair.deployer deployer-key
```

#### Ansible Hosts file

After running `make apply module=ec2-base`, Terraform will create Ansible-compatible hosts file. It will be stored in `ec2-base/generated-hosts.yml`. You can take contents of this file and append to your local hosts file.
Be careful: file will be overwritten each time after issuing `make apply`

#### Running Ansible dependencies installation

Set variable `run_ansible_deps: true' to run dependencies installation through Ansible

### Terraform ec2-node-eth module description

Similar to ec2-base module, differences are:
 - Changed default values for instance type, volume sizes
 - Added secondary storage device