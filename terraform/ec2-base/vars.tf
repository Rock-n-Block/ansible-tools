variable "aws_region" {
  description = "Value of AWS region for account"
  type        = string
  default     = "us-east-2"
}

variable "aws_key_credentials" {
  description = "Value of AWS Access and Secret Key"
  type = object({
    access_key = string
    secret_key = string
  })
  default = {
    access_key = ""
    secret_key = ""
  }
}

variable "aws_profile_name" {
  description = "Value of AWS CLI profile"
  default = "default"
}

variable "instance_ssh_key_file" {
  description = "Value of AWS SSH key file name  to put on server"
  type        = string
  default     = ""
}

variable "instance_ssh_key_priv_file" {
  description = "Value of AWS SSH Private key file name  to run Ansible"
  type        = string
  default     = ""
}

variable "ssh_agent_support" {
  description = "Set to True if you are using SSH Agent and have password-protected private keys"
  type            = bool
  default       = false
}

variable "ami_image" {
  description = "Linux distribution for AMI"
  type: object({
    ubuntu_version = string
    architecture = string
  })
  default = {
    ubuntu_version = "focal-20.04"
    architecture = "arm64"
  }
}

variable "instance_type" {
  description = "Value of Instance Type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "Terraform App Server"
}

variable "instance_organization" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = ""
}

variable "security_rules_ports" {
  description = "Listt of ports to apply in security rules"
  type        = list(any)
  default     = [22, 80, 443]
}

variable "root_block_device" {
  description = "Values of parameters for root disk"
  type = object({
    volume_type = string
    volume_size = number
    iops = number
    throughput = number
  })
  default = {
    volume_type = "gp2"
    volume_size = 30
    iops = 3000
    throughput = 125
  }
}

variable "run_ansible_deps" {
  description = "Installs deps via Ansible playbook"
  type = bool
  default = true
}