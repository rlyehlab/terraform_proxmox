locals {
  vm_ipv4_candidates = [
    for ips in proxmox_virtual_environment_vm.vm_clone.ipv4_addresses :
    ips[0]
    if length(ips) > 0 && !startswith(ips[0], "127.")
  ]
}

output "vm_ipv4_address" {
  description = "Primary IPv4 address assigned to the VM via DHCP"
  value       = length(local.vm_ipv4_candidates) > 0 ? local.vm_ipv4_candidates[0] : "IP not yet available"
}

