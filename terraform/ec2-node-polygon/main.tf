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
  module_name = "ec2-node-polygon"
}

module "ec2-node-polygon" {
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
  storage_block_devices = [var.storage_block_device]
  run_ansible_deps = var.run_ansible_deps
}

resource "null_resource" "ansible_provision_mount_ebs" {
    count = var.run_ansible_mount_ebs? 1 : 0
     depends_on = [module.ec2-node-polygon.ansible_provision_id]
    
    # We making ssh connection in order to wait until intance will be actually reachable
    provisioner "remote-exec" {
      connection {
        type = "ssh"
        host = module.ec2-node-polygon.instance_elastic_ip
        user = "ubuntu"
        agent = var.ssh_agent_support
        private_key = var.ssh_agent_support? "" : file(var.instance_ssh_key_priv_file) 
      }

      inline = ["echo 'connected!'"]
    }
  
    # Mount EBS volume through Ansible
    provisioner "local-exec" {
      command = "cd $ANSIBLE_PATH && make $ANSIBLE_COMMAND hosts_path=$HOSTS_PATH host=$HOST"
      environment = {
        ANSIBLE_PATH = "../../ansible"
        ANSIBLE_COMMAND = "mount-second-ebs"
        HOSTS_PATH = "../terraform/${local.module_name}/${module.ec2-node-polygon.ansible_hosts_filename}"
        HOST = "'${module.ec2-node-polygon.instance_canonical_name}'"
      }
    }

}

resource "null_resource" "ansible_provision_polygon_deps_setup" {
    count = var.run_ansible_bsc_deps_setup? 1 : 0
    depends_on = [null_resource.ansible_provision_mount_ebs]
    
    # We making ssh connection in order to wait until intance will be actually reachable
    provisioner "remote-exec" {
      connection {
        type = "ssh"
        host = module.ec2-node-polygon.instance_elastic_ip
        user = "ubuntu"
        agent = var.ssh_agent_support
        private_key = var.ssh_agent_support? "" : file(var.instance_ssh_key_priv_file) 
      }

      inline = ["echo 'connected!'"]
    }
  
    # Mount EBS volume through Ansible
    provisioner "local-exec" {
      command = "cd $ANSIBLE_PATH && make $ANSIBLE_COMMAND hosts_path=$HOSTS_PATH host=$HOST"
      environment = {
        ANSIBLE_PATH = "../../ansible"
        ANSIBLE_COMMAND = "polygon-deps-setup"
        HOSTS_PATH = "../terraform/${local.module_name}/${module.ec2-node-polygon.ansible_hosts_filename}"
        HOST = "'${module.ec2-node-polygon.instance_canonical_name}'"
      }
    }

}


output "ansible_hosts_filename" {
  description = "Path to Ansible Hosts file"
  value = module.ec2-node-polygon.ansible_hosts_filename
}

output "instance_ip" {
  description = "Path to Ansible Hosts file"
  value = module.ec2-node-polygon.instance_elastic_ip
}