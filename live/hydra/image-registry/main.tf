module "vm" {
  source = "../../../modules/proxmox_vm"

  proxmox_node_name        = var.node_name
  password                 = var.password
  vm_name                  = var.vm_name
  memory                   = var.memory
  vm_id                    = var.vm_id
  cores                    = var.cores
  disk_size                = var.disk_size
  template_name            = var.template_name
  template_map             = local.template_map
  network_bridge           = var.network_bridge
  tags                     = var.tags
  vm_user                  = var.vm_user
  ssh_keys                 = local.ssh_keys
  use_cloud_init_user_data = var.use_cloud_init_user_data
}
