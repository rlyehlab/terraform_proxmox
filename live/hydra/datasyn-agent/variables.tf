variable "proxmox_api_url" {
  description = "URL de la API de Proxmox"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token" {
  description = "id=secret"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "VM password"
  type        = string
  sensitive   = true
}

variable "proxmox_ssh_username" {
  description = "Linux/PAM user for Proxmox SSH (required to upload cloud-init snippets)"
  type        = string
  default     = "root"
}

variable "proxmox_ssh_password" {
  description = "Password for Proxmox SSH (root@pam). Leave empty to use ssh-agent instead."
  type        = string
  sensitive   = true
  default     = ""
}

variable "node_name" {
  description = "Nombre del nodo donde vive la vm"
  type        = string
  default     = "hydra"
}

variable "use_cloud_init_user_data" {
  description = "Upload custom cloud-init user-data (requires Datastore.Allocate on the snippets datastore)"
  type        = bool
  default     = true
}

variable "vm_name" {
  type = string
}

variable "vm_id" {
  type = number
}

variable "memory" {
  type = number
}

variable "cores" {
  type = number
}

variable "disk_size" {
  type = number
}

variable "template_name" {
  type = string
}

variable "network_bridge" {
  description = "Proxmox bridge for the VM network interface"
  type        = string
  default     = "vmbr1"
}

variable "ipv4_address" {
  description = "IPv4 in CIDR notation or \"dhcp\""
  type        = string
  default     = "dhcp"
}

variable "ipv4_gateway" {
  description = "IPv4 gateway; required when ipv4_address is static"
  type        = string
  default     = null
}

variable "tags" {
  type = list(string)
}

variable "vm_user" {
  type = string
}
