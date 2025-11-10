# Crear una máquina virtual en Proxmox
resource "proxmox_vm_qemu" "terraform_vm" {
  name        = var.vm_name
  vmid        = var.vm_id
  target_node = var.target_node
  desc        = "VM creada con Terraform"

  # Configuración de hardware
  cores   = var.vm_cores
  memory  = var.vm_memory
  agent   = 1
  os_type = "cloud-init"

  # Disco principal
  disk {
    type    = "scsi"
    storage = var.vm_storage
    size    = var.vm_disk_size
    format  = "raw"
  }

  # Configuración de red
  network {
    model  = "virtio"
    bridge = var.network_bridge
  }

  # Configuración de cloud-init (opcional)
  ciuser     = "terraform"
  cipassword = "terraform123"
  sshkeys    = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCGeLU9MtiXkJkNIP1ZEU/bbnPD3yB80w0yA4PxEvdih8nqWLHO/4jO4wSi3gDN/AwDAPry6AeY401bgdnP0y8pG63xMQyx/qS2yp4089mUJ37jorG8CEge1WObk2e3Sm0dux+c2SI3vKNN1y3sq1vhmFg4QkvgnIfb9p9KX1lvGjhfT1piR7OORaHR15GVcS1Yu5a1d6UzPr+5E1j/oT+amloeInjlLqneRK1PwDz46oSj90QAnv8pXuu5YvzYlKp+B3Dk0j+CWQ6cSY0T0PgTvBdRGXMzjZNfQZQX67a1Ave7hYC2PWB9UqmFMUvfh5XZMs21CzfHIWDoys/f1KH1/JykL/Q/5aYh9OhNATtdLs79O96ZLu1A0Ltlt6vaDfy+1T2FtCLQVmIqsczdvFZKi6aD+jgTTEZ/KrSNykm93VvwfCBQZyASYtM3HNPwRZPWtSj2KfA8XlixxGyBnyjb5KHwAm3YaXzId1m5kzNBdQ8kcWBHgMpLAref9KcBawjXzV2Yh4BdHceWe/e8+083oFnolfIWvLXyxtPNb3qUf0Ri8rMJN2nwOjcQ/SFQTme8CEDllvisZWGY0BIjO7HTXXXa+nAlMCgk1a/16duds1yTXEZ+olCB5zM2fsuu5tY7bLUR0YbqjEzkW1jm5/f0beEP2cvWLkzdrgeNSYT5lw== caripa.front@gmail.com
EOF

  # Imagen ISO para instalación (descomentar si necesitas instalar desde ISO)
  # disk {
  #   type    = "ide"
  #   storage = "local"
  #   size    = "1G"
  #   media   = "cdrom"
  #   file    = var.iso_file
  # }

  lifecycle {
    ignore_changes = [
      network,
      disk
    ]
  }
}

