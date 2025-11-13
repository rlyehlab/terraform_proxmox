# https://registry.terraform.io/providers/bpg/proxmox/latest/docs/guides/clone-vm
resource "proxmox_virtual_environment_vm" "ubuntu_clone" {
  description = "Managed by proxmox"
  name        = var.vm_name
  node_name   = var.proxmox_node_name
  vm_id       = var.vm_id

  stop_on_destroy = true
  agent {
    # NOTE: The agent is installed and enabled as part of the cloud-init configuration in the template VM, see cloud-config.tf
    # The working agent is *required* to retrieve the VM IP addresses.
    # If you are using a different cloud-init configuration, or a different clone source
    # that does not have the qemu-guest-agent installed, you may need to disable the `agent` below and remove the `vm_ipv4_address` output.
    # See https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm#qemu-guest-agent for more details.
    enabled = true
  }

  clone {
    vm_id = 6009
  }
  # if agent is not enabled, the VM may not be able to shutdown properly, and may need to be forced off
  memory {
    dedicated = 2048
  }

  initialization {
    dns {
      servers = ["1.1.1.1"]
    }
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}
