module "test" {
  source = "../../modules/proxmox_vm"

  proxmox_node_name = var.node_name
  password          = var.password
  vm_name           = var.test.name
  memory            = var.test.memory
  vm_id             = var.test.id
  cores             = var.test.cores
  disk_size         = var.test.disk_size
  template_name     = var.test.template_name
  tags              = var.test.tags
  vm_user           = var.test.vm_user
  ssh_keys          = var.test.ssh_keys
  use_static_ip     = var.test.use_static_ip
  static_ip         = var.test.static_ip
}
