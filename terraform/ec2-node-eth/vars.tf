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

# TODO: fetch AMI id from some typical name
variable "instance_ami" {
  description = "Value of Instance AMI for the EC2 instance"
  type        = string
  default     = "ami-008e02c1f94100fd9" # Ubuntu 20.04 ARM64 (us-east-2)
}

variable "instance_type" {
  description = "Value of Instance Type for the EC2 instance"
  type        = string
  default     = "c6g.xlarge"
}

variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "Geth Node"
}

variable "instance_organization" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = ""
}

variable "security_rules_ports" {
  description = "List of ports to apply in security rules"
  type        = list(any)
  default     = [22, 80, 443, 8545, 8546]
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
    volume_type = "gp3"
    volume_size = 80
    iops = 4000
    throughput = 350
  }
}

variable "storage_block_device" {
  description = "Values of parameters for root disk"
  type = object({
    volume_type = string
    volume_size = number
    iops = number
    throughput = number
  })
  default = {
    volume_type = "gp3"
    volume_size = 800
    iops = 4000
    throughput = 350
  }
}

variable "run_ansible_deps" {
  description = "Installs deps via Ansible playbook"
  type = bool
  default = true
}

variable "run_ansible_mount_ebs" {
  description = "Mount secondary EBS volume via Ansible playbook"
  type = bool
  default = true
}

variable "run_ansible_launch_geth" {
  description = "Setup and launch Go-Ethereum"
  type = bool
  default = true
}