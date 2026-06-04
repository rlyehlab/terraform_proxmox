# module "testing" {
#   source = "../../modules/proxmox_vm"

#   proxmox_node_name = var.node_name
#   vm_name           = var.testing.name
#   memory            = var.testing.memory
#   vm_id             = var.testing.id
#   cores             = var.testing.cores
#   disk_size         = var.testing.disk_size
#   template_name     = var.testing.template_name
#   tags              = var.testing.tags
#   password          = var.password
#   vm_user           = var.testing.vm_user
#   ssh_keys          = var.testing.ssh_keys
# }

module "pad" {
  source = "../../modules/proxmox_vm"

  proxmox_node_name = var.node_name
  password          = var.password
  vm_name           = var.pad.name
  memory            = var.pad.memory
  vm_id             = var.pad.id
  cores             = var.pad.cores
  disk_size         = var.pad.disk_size
  template_name     = var.pad.template_name
  tags              = var.pad.tags
  vm_user           = var.pad.vm_user
  ssh_keys          = var.pad.ssh_keys
}

module "wiki" {
  source = "../../modules/proxmox_vm"

  proxmox_node_name = var.node_name
  password          = var.password
  vm_name           = var.wiki.name
  memory            = var.wiki.memory
  vm_id             = var.wiki.id
  cores             = var.wiki.cores
  disk_size         = var.wiki.disk_size
  template_name     = var.wiki.template_name
  tags              = var.wiki.tags
  vm_user           = var.wiki.vm_user
  ssh_keys          = var.wiki.ssh_keys
}

module "nextcloud" {
  source = "../../modules/proxmox_vm"

  proxmox_node_name = var.node_name
  password          = var.password
  vm_name           = var.nextcloud.name
  memory            = var.nextcloud.memory
  vm_id             = var.nextcloud.id
  cores             = var.nextcloud.cores
  disk_size         = var.nextcloud.disk_size
  template_name     = var.nextcloud.template_name
  tags              = var.nextcloud.tags
  vm_user           = var.nextcloud.vm_user
  ssh_keys          = var.nextcloud.ssh_keys
}
