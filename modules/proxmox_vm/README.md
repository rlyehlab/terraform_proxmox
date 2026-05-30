# proxmox_vm

Module for creating a Proxmox VM via full clone from a template. Uses the [bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest) provider.

## Usage

```hcl
module "my_vm" {
  source = "../../modules/proxmox_vm"

  proxmox_node_name = "hydra"
  vm_name           = "my-vm"
  vm_id             = 201
  password          = var.password
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `vm_name` | VM name | `string` | — | yes |
| `proxmox_node_name` | Proxmox node to create the VM on | `string` | — | yes |
| `vm_id` | VM ID | `number` | — | yes |
| `password` | VM user password | `string` | — | yes |
| `memory` | RAM in MB | `number` | `2048` | no |
| `cores` | CPU cores | `number` | `2` | no |
| `disk_size` | Disk size in GB | `number` | `16` | no |
| `datastore_id` | Proxmox datastore | `string` | `"local-lvm"` | no |
| `template_name` | Template key (`ubuntu` or `debian`) | `string` | `"ubuntu"` | no |
| `template_map` | Map of template name to VM ID | `map(number)` | `{ubuntu=6009, debian=6010}` | no |
| `on_boot` | Start VM on host boot | `bool` | `true` | no |
| `started` | Start VM after creation | `bool` | `true` | no |
| `tags` | List of tags | `list(string)` | `[]` | no |
| `dns_servers` | DNS servers | `list(string)` | `["10.69.69.1"]` | no |
| `description` | VM description | `string` | `"Managed by Terraform"` | no |
| `disk_interface` | Disk interface | `string` | `"virtio0"` | no |
| `disk_file_format` | Disk file format | `string` | `"raw"` | no |
| `disk_discard` | Disk discard mode | `string` | `"on"` | no |
| `disk_ssd` | Emulate SSD | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vm_ipv4_address` | IPv4 address assigned to the VM |
