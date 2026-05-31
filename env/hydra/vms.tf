module "testing" {
  source = "../../modules/proxmox_vm"

  proxmox_node_name = var.node_name
  vm_name           = var.testing.name
  memory            = var.testing.memory
  vm_id             = var.testing.id
  cores             = var.testing.cores
  disk_size         = var.testing.disk_size
  template_name     = var.testing.template_name
  tags              = var.testing.tags
  password          = var.password
  vm_user           = var.testing.vm_user
  ssh_keys          = var.testing.ssh_keys
}
