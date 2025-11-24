# https://registry.terraform.io/providers/bpg/proxmox/latest/docs/guides/clone-vm
resource "proxmox_virtual_environment_vm" "ubuntu_clone" {
  description = "Managed by proxmox"
  name        = var.vm_name
  node_name   = var.proxmox_node_name
  vm_id       = var.vm_id

  cpu {
    cores = var.cores
  }
  
  stop_on_destroy = true
  agent {
    enabled = true
  }

  clone {
    vm_id = 6009
  full  = true
  }

  memory {
    dedicated = var.memory
  }

    disk {
    datastore_id = var.datastore_id
    interface    = "virtio0"
    size         = var.disk_sizes
    file_format  = "raw"
    discard      = "on"
    ssd          = true
  }

  initialization {
    dns {
      servers = ["10.69.69.1"]
    }
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}
