terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

locals {
  module_name = "ec2-base"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile_name
  access_key = var.aws_key_credentials.access_key
  secret_key = var.aws_key_credentials.secret_key
  
}

resource "aws_key_pair" "deployer" {
  key_name = "deployer-key-${local.module_name}"
  public_key = file(var.instance_ssh_key_file)
}

resource "aws_security_group" "app_server_sg" {
  # name = "app-serever-security-group"
  description = "Security group for instance"

  dynamic "ingress" {
    for_each = var.security_rules_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.instance_name
    canonical_name = lower(replace(var.instance_name, " ", "_"))
  }
}

output "aws_security_group_id" {
  description = "ID of the EC2 instance security group"
  value       = aws_security_group.app_server_sg.id
}

output "aws_security_group_name" {
  description = "ID of the EC2 instance security group"
  value       = aws_security_group.app_server_sg.name
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-${var.ami_image.ubuntu_version}-${var.ami_image.architecture}-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name

  root_block_device {
    encrypted   = true
    volume_type = var.root_block_device.volume_type
    volume_size = var.root_block_device.volume_size
    iops = contains(["io1", "io2", "gp3"], var.root_block_device.volume_type) ? var.root_block_device.iops : null
    throughput = var.root_block_device.volume_type == "gp3" ? var.root_block_device.throughput : null

    tags = {
      Name = var.instance_name
      Org  = var.instance_organization
      canonical_name = lower(replace(var.instance_name, " ", "_"))
    }
  }

  tags = {
    Name = var.instance_name
    Org  = var.instance_organization
    canonical_name = lower(replace(var.instance_name, " ", "_"))
  }

  security_groups = [aws_security_group.app_server_sg.name]
}

resource "aws_eip" "app_server_eip" {
  instance = aws_instance.app_server.id

  tags = {
    Name = var.instance_name
    Org  = var.instance_organization
    canonical_name = lower(replace(var.instance_name, " ", "_"))
  }
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_name" {
  description = "Name of the EC2 instance"
  value       = aws_instance.app_server.tags["Name"]
}

output "instance_canonical_name" {
  description = "Canonical name of the EC2 instance"
  value       = aws_instance.app_server.tags["canonical_name"]
}

output "instance_elastic_ip" {
  description = "Elastic IP address of the EC2 instance"
  value       = aws_eip.app_server_eip.public_ip
}

resource "local_file" "ansible_hosts" {
  depends_on = [aws_instance.app_server]
    content = yamlencode({
      "all": {
        "vars": {
          "ansible_user": "ubuntu"
          "ansible_ssh_common_args":"-o StrictHostKeyChecking=no"
        },
        "hosts": {
          "${aws_instance.app_server.tags["canonical_name"]}": {
            "ansible_host": "${aws_eip.app_server_eip.public_ip}"
          }
        }
      }
    })
    filename = "tfgenhosts-${aws_instance.app_server.tags["canonical_name"]}-${aws_instance.app_server.id}.yml"
    file_permission = "0644"
    directory_permission = "0775"

    provisioner "local-exec" {
      command = "cat $FILENAME | tr -d '\"' > $FILENAME.new && mv -f $FILENAME.new $FILENAME"
      environment = {
        FILENAME = local_file.ansible_hosts.filename
      }
    }
}

resource "null_resource" "ansible_provision" {
    depends_on = [local_file.ansible_hosts]
    count = var.run_ansible_deps? 1 : 0
    
    # We making ssh connection in order to wait until intance will be actually reachable
    provisioner "remote-exec" {
      connection {
        type = "ssh"
        host = aws_eip.app_server_eip.public_ip
        user = "ubuntu"
        agent = var.ssh_agent_support
        private_key = var.ssh_agent_support? "" : file(var.instance_ssh_key_priv_file) 
      }

      inline = ["echo 'connected!'"]
    }
  
  # And only after SSH connection, Ansible will be executed
  provisioner "local-exec" {
    command = "cd $ANSIBLE_PATH && make $ANSIBLE_COMMAND hosts_path=$HOSTS_PATH host=$HOST"
    environment = {
      ANSIBLE_PATH = "../../ansible"
      ANSIBLE_COMMAND = "deps"
      HOSTS_PATH = "../terraform/${local.module_name}/${local_file.ansible_hosts.filename}"
      HOST = "'${aws_instance.app_server.tags["canonical_name"]}'"
    }
  }
}
