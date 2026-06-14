vm_name       = "Nextcloud"
memory        = 4096
vm_id          = 112
network_bridge = "vmbr1"
ipv4_address   = "10.13.10.102/24"
ipv4_gateway   = "10.13.10.1"
cores         = 2
disk_size     = 8
template_name = "ubuntu"
tags          = ["terraform", "ubuntu", "production"]
vm_user       = "user"
agent_enabled = false
ssh_keys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDcNcHVpSVDCUpyfX8u3IU79tq3YC/+t8ROBb/4FKKG vlad@rlab.com",
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID8z+XOiIZhrCbeMO6pJjQtU29YAheChLkUeVnZueMH8 odradek@rlab.be",
]
