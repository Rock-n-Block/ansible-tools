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

resource "aws_key_pair" "deployer" {
  key_name = "deployer-key"
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

resource "aws_instance" "app_server" {
  ami           = var.instance_ami
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
    filename = "generated-hosts.yml"
    file_permission = "0644"
    directory_permission = "0775"
}

resource "null_resource" "ansible_provision" {
    depends_on = [local_file.ansible_hosts]
    
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
    command = "cd ../../ansible && make deps hosts_path=../terraform/ec2-general/generated-hosts.yml host='${aws_instance.app_server.tags["canonical_name"]}'"
  }
}
