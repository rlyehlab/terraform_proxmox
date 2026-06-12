vm_name       = "Controller"
memory        = 1024
vm_id         = 113
cores         = 2
template_name = "ubuntu"
tags          = ["terraform", "ubuntu", "production"]
vm_user       = "user"
ssh_keys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDcNcHVpSVDCUpyfX8u3IU79tq3YC/+t8ROBb/4FKKG vlad@rlab.com",
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID8z+XOiIZhrCbeMO6pJjQtU29YAheChLkUeVnZueMH8 odradek@rlab.be",
]
