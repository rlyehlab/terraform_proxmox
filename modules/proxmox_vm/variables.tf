variable "password" {
  description = "Cloud-init user password"
  type        = string
  sensitive   = true
}

variable "proxmox_node_name" {
  description = "Proxmox node where the VM will be created"
  type        = string
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "vm_id" {
  description = "Proxmox VM ID (100–9999)"
  type        = number
  validation {
    condition     = var.vm_id >= 100 && var.vm_id <= 9999
    error_message = "vm_id must be between 100 and 9999."
  }
}

variable "memory" {
  description = "RAM allocated to the VM in MB"
  type        = number
  default     = 2048
  validation {
    condition     = var.memory >= 256
    error_message = "memory must be at least 256 MB."
  }
}

variable "cores" {
  description = "Number of dedicated CPU cores"
  type        = number
  default     = 2
  validation {
    condition     = var.cores >= 1
    error_message = "cores must be at least 1."
  }
}

variable "datastore_id" {
  description = "Proxmox datastore where the disk will be created"
  type        = string
  default     = "tank"
}

variable "initialization_datastore_id" {
  description = "Proxmox datastore for the cloud-init drive (ide2)"
  type        = string
  default     = "local-lvm"
}

variable "cloudinit_snippets_datastore_id" {
  description = "Proxmox datastore for cloud-init snippet files (must support the snippets content type)"
  type        = string
  default     = "local"
}

variable "use_cloud_init_user_data" {
  description = "Upload custom cloud-init user-data to force a fresh instance-id and apply SSH keys/password on clone"
  type        = bool
  default     = false
}

variable "disk_size" {
  description = "Grow the root disk to this size in GB (null = use template disk as-is, must be >= template disk size)"
  type        = number
  default     = null
}

variable "disk_interface" {
  description = "Disk interface of the root disk to resize (e.g. scsi0, virtio0)"
  type        = string
  default     = "scsi0"
}

variable "disk_file_format" {
  description = "Disk file format (e.g. raw, qcow2)"
  type        = string
  default     = "raw"
}

variable "disk_discard" {
  description = "Disk discard/trim setting"
  type        = string
  default     = "on"
}

variable "disk_ssd" {
  description = "Emulate SSD for the disk"
  type        = bool
  default     = true
}

variable "template_map" {
  description = "Map of template names to their Proxmox VM IDs"
  type        = map(number)
  default = {
    ubuntu = 6009
    debian = 6010
    alpine = 6011
    fedora = 6012
  }
}

variable "template_name" {
  description = "Key from template_map to use as the clone source"
  type        = string
  default     = "ubuntu"
  validation {
    condition     = contains(keys(var.template_map), var.template_name)
    error_message = "template_name must be a key defined in template_map."
  }
}

variable "dns_servers" {
  description = "List of DNS servers for cloud-init"
  type        = list(string)
  default     = ["10.69.69.1"]
}

variable "tags" {
  description = "List of tags to assign to the VM"
  type        = list(string)
  default     = []
}

variable "description" {
  description = "VM description shown in Proxmox"
  type        = string
  default     = "Managed by Terraform"
}

variable "on_boot" {
  description = "Start the VM automatically when the Proxmox node boots"
  type        = bool
  default     = true
}

variable "started" {
  description = "Whether the VM should be running after creation"
  type        = bool
  default     = true
}

variable "vm_user" {
  type    = string
  default = "admin"
}

variable "ssh_keys" {
  type    = list(string)
  default = []
}

variable "network_bridge" {
  description = "Proxmox bridge for net0 (e.g. vmbr0, vmbr2)"
  type        = string
  default     = "vmbr0"
}

variable "ipv4_address" {
  description = "IPv4 in CIDR notation (e.g. 10.69.69.50/24) or \"dhcp\""
  type        = string
  default     = "dhcp"

  validation {
    condition     = var.ipv4_address == "dhcp" || can(regex("^\\d+\\.\\d+\\.\\d+\\.\\d+/\\d+$", var.ipv4_address))
    error_message = "ipv4_address must be \"dhcp\" or a CIDR address (e.g. 10.69.69.50/24)."
  }
}

variable "ipv4_gateway" {
  description = "IPv4 gateway; required when ipv4_address is static; omit for dhcp"
  type        = string
  default     = null

  validation {
    condition     = var.ipv4_address == "dhcp" || (var.ipv4_gateway != null && var.ipv4_gateway != "")
    error_message = "ipv4_gateway is required when ipv4_address is not \"dhcp\"."
  }
}

variable "bios" {
  description = "BIOS type (seabios or ovmf for UEFI)"
  type        = string
  default     = "seabios"
}

variable "machine" {
  description = "Machine type (e.g. q35); null leaves Proxmox default"
  type        = string
  default     = null
}

variable "enable_efi_disk" {
  description = "Create EFI disk (required for ovmf/UEFI boot)"
  type        = bool
  default     = false
}

variable "efi_disk_datastore_id" {
  description = "Datastore for EFI disk when enable_efi_disk is true"
  type        = string
  default     = "local-lvm"
}

variable "vendor_data_file_id" {
  description = "Proxmox cloud-init vendor-data snippet file ID (optional)"
  type        = string
  default     = null
}

variable "agent_enabled" {
  description = "Enable QEMU guest agent (disable if agent hangs plan/apply refresh)"
  type        = bool
  default     = true
}
