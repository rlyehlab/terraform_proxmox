### Testing VM

# testing = {
#   name          = "Testing"
#   memory        = 2048
#   id            = 6010
#   cores         = 2
#   disk_size     = 16
#   template_name = "debian"
#   tags          = ["terraform", "debian", "testing"]
#   vm_user       = "admin"
#   ssh_keys      = [ 
#     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDcNcHVpSVDCUpyfX8u3IU79tq3YC/+t8ROBb/4FKKG vlad@rlab.com",
#     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID8z+XOiIZhrCbeMO6pJjQtU29YAheChLkUeVnZueMH8 odradek@rlab.be"
#   ]
# }

### PAD VM

pad = {
  name          = "Pad"
  memory        = 1024
  id            = 103
  cores         = 2
  disk_size     = 8
  template_name = "debian"
  tags          = ["terraform", "debian", "production"]
  vm_user       = "user"
  ssh_keys      = [ 
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDcNcHVpSVDCUpyfX8u3IU79tq3YC/+t8ROBb/4FKKG vlad@rlab.com",
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID8z+XOiIZhrCbeMO6pJjQtU29YAheChLkUeVnZueMH8 odradek@rlab.be"
  ]
}