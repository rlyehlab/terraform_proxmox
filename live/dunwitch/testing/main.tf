module "vm" {
  source = "../../../modules/proxmox_vm"

  proxmox_node_name = var.node_name
  password          = var.password
  vm_name           = var.vm_name
  memory            = var.memory
  vm_id             = var.vm_id
  cores             = var.cores
  disk_size         = var.disk_size
  template_name     = var.template_name
  tags              = var.tags
  vm_user           = var.vm_user
  ssh_keys          = var.ssh_keys
  ipv4_address      = var.ipv4_address
  ipv4_gateway      = var.ipv4_gateway
}
