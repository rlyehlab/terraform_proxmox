vm_name       = "Wiki"
memory        = 2048
vm_id          = 111
network_bridge = "vmbr1"
ipv4_address   = "10.13.10.100/24"
ipv4_gateway   = "10.13.10.1"
cores         = 2
template_name = "debian"
tags          = ["terraform", "debian", "production"]
vm_user       = "user"
ssh_keys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDcNcHVpSVDCUpyfX8u3IU79tq3YC/+t8ROBb/4FKKG vlad@rlab.com",
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID8z+XOiIZhrCbeMO6pJjQtU29YAheChLkUeVnZueMH8 odradek@rlab.be",
]
