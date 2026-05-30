output "vm_ipv4_address" {
  description = "Primary IPv4 address assigned to the VM via DHCP"
  value       = proxmox_virtual_environment_vm.vm_clone.ipv4_addresses[1][0]
}

