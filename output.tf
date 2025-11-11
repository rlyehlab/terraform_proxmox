output "vm_ip_address" {
  description = "Dirección IP de la VM"
  value       = proxmox_vm_qemu.terraform_vm.default_ipv4_address
}

output "vm_id" {
  description = "ID de la VM en Proxmox"
  value       = proxmox_vm_qemu.terraform_vm.vmid
}

output "vm_name" {
  description = "Nombre de la VM"
  value       = proxmox_vm_qemu.terraform_vm.name
}

output "vm_status" {
  description = "Estado de la VM"
  value       = proxmox_vm_qemu.terraform_vm.vm_state
}
