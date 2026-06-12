locals {
  cloud_init_user_data = <<-EOT
#cloud-config
instance-id: terraform-proxmox-vm-${var.vm_id}
hostname: ${var.vm_name}
users:
  - name: ${var.vm_user}
    lock_passwd: false
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash
    ssh_authorized_keys:
${join("\n", [for key in var.ssh_keys : "      - ${trimspace(key)}"])}
chpasswd:
  list: |
    ${var.vm_user}:${var.password}
  expire: false
ssh_pwauth: true
EOT
}

resource "proxmox_virtual_environment_file" "cloud_init_user_data" {
  count = var.use_cloud_init_user_data ? 1 : 0

  content_type = "snippets"
  datastore_id = var.cloudinit_snippets_datastore_id
  node_name    = var.proxmox_node_name
  overwrite    = true

  source_raw {
    data      = local.cloud_init_user_data
    file_name = "terraform-vm-${var.vm_id}-user-data.yaml"
  }
}
