aws_region = "us-east-2"                                 # Region of EC2 instance
aws_key_credentials = {
    access_key = ""                                      # AWS Access Key (optional if  AWS CLI profile is used)
    secret_key = ""                                      # AWS Secret Key (optional if  AWS CLI profile is used)
}
aws_profile_name = ""                                    # AWS Access Key (optional if  Aceess and Secret keys are  used)
instance_ssh_key_file = "/home/user/.ssh/id_rsa.pub"     # SSH Public key to deploy on instance
instance_ssh_key_priv_file = "/home/user/.ssh/id_rsa"    # Path to SSH Private key
ssh_agent_support = false                                # (Optional) Enable support for SSH Agent for connections
instance_ami = "ami-008e02c1f94100fd9"                   # Instance AMI ID (default: Ubuntu 20.04 ARM)
instance_type = "r6g.xlarge"                               # Instance type 
instance_name = "Terraform EC2 Geth Node"                # Instance '"Name" tag 
instance_organization = "RNB"                            # (Optional) Instance "Organization" tag  (will not be set if  equals "")
security_rules_ports = [22, 80, 443, 8545, 8546]                     # Ports for security group
root_block_device = {
    volume_type = "gp3"                                  # Type of volume
    volume_size = 80                                     # Size of root volume
    iops = 4000                                          # (Optional) Amount of provisioned IOPS. Only valid for volume_type of io1, io2 or gp3 (default: 3000)
    throughput = 350                                     # (Optional) Throughput for a volume (MiB/s). This is only valid for volume_type of gp3 (default: 125
}
storage_block_device = {
    volume_type = "gp3"                                  # Type of volume
    volume_size = 800                                     # Size of storage volume
    iops = 4000                                          # (Optional) Amount of provisioned IOPS. Only valid for volume_type of io1, io2 or gp3 (default: 3000)
    throughput = 350                                     # (Optional) Throughput for a volume (MiB/s). This is only valid for volume_type of gp3 (default: 125
}
run_ansible_deps = true
run_ansible_mount_ebs = true                 