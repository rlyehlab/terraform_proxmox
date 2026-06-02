### Testing VM

# testing = {
#   name          = "Testing"
#   memory        = 2048
#   id            = 6010
#   cores         = 2
#   # disk_size grows the root disk (scsi0) beyond the template size (8GB).
#   # Omit or set to null to use the template disk as-is.
#   disk_size     = 32
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
  memory        = 2048
  id            = 103
  cores         = 2
  template_name = "debian"
  tags          = ["terraform", "debian", "production"]
  vm_user       = "user"
  ssh_keys      = [ 
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDcNcHVpSVDCUpyfX8u3IU79tq3YC/+t8ROBb/4FKKG vlad@rlab.com",
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID8z+XOiIZhrCbeMO6pJjQtU29YAheChLkUeVnZueMH8 odradek@rlab.be"
  ]
}