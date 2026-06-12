locals {
  # Ubuntu 20.04 cloud-init template (create_template/ubuntu/create-template.sh)
  template_map = {
    ubuntu = 6013
    debian = 6010
    alpine = 6011
    fedora = 6012
  }

  ssh_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG0rSR/UDsdCxH2p39z4VUgIZ5ytop1AR/YyjGuG+ucx vlad@rlab.com-datasyn",
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID8z+XOiIZhrCbeMO6pJjQtU29YAheChLkUeVnZueMH8 odradek@rlab.be",
  ]
}
