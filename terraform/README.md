# Terraform EC2  

## Overview

This repo contains Terraform configuration for AWS EC2 instance deployment

### Supported features
- EC2 deployment
- Security Group creation
- SSH Key import
- Tag assigment on instances/security groups/block devices

### Customizable parameters:
- AWS Provider settings (login by Acces & Secret keys or AWS CLI profile)
- SSH key to setup
- EC2 AMI (currently raw AMI ID supported)
- EC2 Storage type
- EC2 Instance type
- Secutiry Group exposed ports
- Tags (Name, Org) are currently supported

## Prerequesites

* Terraform
* AWS CLI
* Ansible

### Note on SSH connections

By default, password-protected (encrypted) private ssh keys are not supported in Terraform
But, if you use such key and some sort of ssh agent, you can set variable `ssh_agent_support = true` to utilize ssh agent

## Variables and  configuration

Copy `vars-example.tfvars` to `terraform.tfvars` or other `some-vars-file.tfvars` file
```bash
cp vars-example.tfvars terraform.tfvars
```
Adjust `.tfvars` file according to your needs


---

Terraform automatically loads a number of variable definitions files if they are present:
 - Files named exactly terraform.tfvars
 - Any files with names ending in .auto.tfvars

Or you can use option `-vars-file="new-production.tfvars"` to specify vars file in commands:
```bash
terraform apply -var-file="testing.tfvars"
```

## Importing existing keys

If you changing state, but SSH key was already created on AWS, Terraform will create error.
In order to make it work with already imported key, you need to refresh your local state with key that exist on AWS:
```bash
terraform import aws_key_pair.deployer deployer-key
```

## Modules

ec2-general - module for deploying customisable EC2 instances

## Usage and commands

`vars_file` - file of Terraform variables (must be places in this directory)

Available modules:
 - ec2-general

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

List workspaces
```bash
make workspace_list <name_of_workspace>
```

Change workspace
```bash
make workspace_select <name_of_workspace>
```

Create new workspace
```bash
make workspace_new <name_of_workspace>
```
