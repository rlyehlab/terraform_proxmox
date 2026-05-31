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
  default     = "local-lvm"
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 16
}

variable "disk_interface" {
  description = "Disk interface (e.g. virtio0, scsi0)"
  type        = string
  default     = "virtio0"
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