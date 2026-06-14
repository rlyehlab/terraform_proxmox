locals {
  vm_ipv4_candidates = [
    for ips in proxmox_virtual_environment_vm.vm_clone.ipv4_addresses :
    ips[0]
    if length(ips) > 0 && !startswith(ips[0], "127.")
  ]

  vm_ipv4_static = var.ipv4_address != "dhcp" ? split("/", var.ipv4_address)[0] : null
}

output "vm_ipv4_address" {
  description = "Primary IPv4 address (static from config, or discovered via QEMU guest agent for DHCP)"
  value = local.vm_ipv4_static != null ? local.vm_ipv4_static : (
    length(local.vm_ipv4_candidates) > 0 ? local.vm_ipv4_candidates[0] : "IP not yet available"
  )
}

