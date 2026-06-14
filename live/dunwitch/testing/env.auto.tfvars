vm_name       = "Testing"
memory        = 2048
vm_id          = 201
ipv4_address   = "10.69.69.201/24"
ipv4_gateway   = "10.69.69.1"
cores         = 2
disk_size     = 16
template_name = "debian"
tags          = ["terraform", "debian", "testing"]
vm_user       = "admin"
ssh_keys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDcNcHVpSVDCUpyfX8u3IU79tq3YC/+t8ROBb/4FKKG vlad@rlab.com",
]
