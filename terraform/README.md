# Terraform Tools  


## Overview

This repo contains Terraform configurations for automated tasks

## Prerequesites

* Terraform
* AWS CLI
* Ansible

## Basic usage

### Variables and  configuration

Copy `vars-example.tfvars` to `terraform.tfvars` or other `some-vars-file.tfvars` file
```bash
cp vars-example.tfvars terraform.tfvars
```
Adjust `.tfvars` file according to your needs


Terraform automatically loads a number of variable definitions files if they are present:
 - Files named exactly terraform.tfvars
 - Any files with names ending in .auto.tfvars

Or you can use option `-vars-file="new-production.tfvars"` to specify vars file in commands:
```bash
terraform apply -var-file="testing.tfvars"
```

### Deployment commands

`vars_file` - file of Terraform variables (must be places in this directory)
`name_of_module` - name of module to use (listed below)

Validate configuration
```bash
terraform validate module=<name_of_module> vars=<vars_file>
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
make show module=<name_of_module> vars=<vars_file>
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
make workspace_list module=<name_of_module> workspace=<name_of_workspace>
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


#### Ansible Hosts file

After running `make apply module=ec2-base`, Terraform will create Ansible-compatible hosts file. It will be stored in `ec2-base/generated-hosts.yml`. You can take contents of this file and append to your local hosts file.
Be careful: file will be overwritten each time after issuing `make apply`



#### Importing existing keys

If you changing state, but SSH key was already created on AWS, Terraform will create error.
In order to make it work with already imported key, you need to refresh your local state with key that exist on AWS:
```bash
make import_key module=<namme_of_module> aws_key_pair.deployer deployer-key
```