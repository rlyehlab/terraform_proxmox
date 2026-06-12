# https://registry.terraform.io/providers/bpg/proxmox/latest/docs/guides/clone-vm
resource "proxmox_virtual_environment_vm" "vm_clone" {
  description     = var.description
  name            = var.vm_name
  node_name       = var.proxmox_node_name
  vm_id           = var.vm_id
  on_boot         = var.on_boot
  tags            = var.tags
  started         = var.started
  stop_on_destroy = true

  cpu {
    cores = var.cores
  }

  agent {
    enabled = true
    timeout = "15m"
  }

  clone {
    vm_id = var.template_map[var.template_name]
    full  = true
  }

  memory {
    dedicated = var.memory
  }

  dynamic "disk" {
    for_each = var.disk_size != null ? [1] : []
    content {
      datastore_id = var.datastore_id
      interface    = var.disk_interface
      size         = var.disk_size
      file_format  = var.disk_file_format
      discard      = var.disk_discard
      ssd          = var.disk_ssd
    }
  }

  initialization {
    datastore_id      = var.initialization_datastore_id
    interface         = "ide2"
    user_data_file_id = var.use_cloud_init_user_data ? proxmox_virtual_environment_file.cloud_init_user_data[0].id : null

    dns {
      servers = var.dns_servers
    }

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    dynamic "user_account" {
      for_each = var.use_cloud_init_user_data ? [] : [1]
      content {
        username = var.vm_user
        password = var.password
        keys     = [for key in var.ssh_keys : trimspace(key)]
      }
    }
  }
}
