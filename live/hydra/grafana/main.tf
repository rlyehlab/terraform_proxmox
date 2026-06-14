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
  network_bridge    = var.network_bridge
  agent_enabled     = var.agent_enabled

  # UEFI + custom vendor cloud-init (same pattern as nextcloud/controller).
  bios                  = "ovmf"
  machine               = "q35"
  enable_efi_disk       = true
  efi_disk_datastore_id = "local-lvm"
  vendor_data_file_id   = "local:snippets/ubuntu-noble.yaml"
  datastore_id          = "local-lvm"
  disk_interface        = "virtio0"
  disk_ssd              = false
}
