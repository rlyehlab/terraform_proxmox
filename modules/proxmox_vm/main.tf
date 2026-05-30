# https://registry.terraform.io/providers/bpg/proxmox/latest/docs/guides/clone-vm
resource "proxmox_virtual_environment_vm" "vm_clone" {
  description = var.description
  name        = var.vm_name
  node_name   = var.proxmox_node_name
  vm_id       = var.vm_id
  on_boot     = var.on_boot
  tags        = var.tags
  started     = var.started

  cpu {
    cores = var.cores
  }
  
  stop_on_destroy = true
  agent {
    enabled = true
  }

  clone {
    vm_id = var.template_map[var.template_name]
    full  = true
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.datastore_id
    interface    = var.disk_interface
    size         = var.disk_size
    file_format  = var.disk_file_format
    discard      = var.disk_discard
    ssd          = var.disk_ssd
  }

  initialization {
    dns {
      servers = var.dns_servers
    }
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}
