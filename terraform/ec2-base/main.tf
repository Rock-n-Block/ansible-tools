terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile_name
  access_key = var.aws_key_credentials.access_key
  secret_key = var.aws_key_credentials.secret_key
  
}

locals {
  module_name = "ec2-base"
}

module "ec2-base" {
  source = "../core/ec2"

  module_name = local.module_name

  ssh_agent_support = var.ssh_agent_support
  instance_ssh_key_file = var.instance_ssh_key_file
  instance_ssh_key_priv_file = var.instance_ssh_key_priv_file
  security_rules_ports = var.security_rules_ports
  instance_name = var.instance_name
  instance_organization = var.instance_organization
  ami_image = var.ami_image
  instance_type = var.instance_type
  root_block_device = var.root_block_device
  run_ansible_deps = var.run_ansible_deps
}

output "ansible_hosts_filename" {
  description = "Path to Ansible Hosts file"
  value = module.ec2-base.ansible_hosts_filename
}

output "instance_ip" {
  description = "Path to Ansible Hosts file"
  value = module.ec2-base.instance_elastic_ip
}