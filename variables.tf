# Variables de autenticación
variable "proxmox_api_url" {
  description = "URL de la API de Proxmox"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_id" {
  description = "ID del token de API (ej: user@pve!token-name)"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "Secret del token de API"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Si se debe aceptar certificados TLS no verificados"
  type        = bool
  default     = true
}

variable "proxmox_debug" {
  description = "Habilitar modo debug para el provider"
  type        = bool
  default     = false
}

# Variables para la VM
variable "vm_name" {
  description = "Nombre de la máquina virtual"
  type        = string
  default     = "testing"
}

variable "vm_id" {
  description = "ID de la máquina virtual"
  type        = number
  default     = 200
}

variable "proxmox_node_name" {
  description = "Nodo de Proxmox donde crear la VM"
  type        = string
}

variable "vm_cores" {
  description = "Número de cores de la VM"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Memoria en MB para la VM"
  type        = number
  default     = 2048
}

variable "vm_disk_size" {
  description = "Tamaño del disco en GB"
  type        = string
  default     = "20G"
}

variable "vm_storage" {
  description = "Almacenamiento donde crear el disco"
  type        = string
  default     = "local-lvm"
}

variable "iso_file" {
  description = "Archivo ISO para instalar el SO"
  type        = string
  default     = "local:iso/ubuntu-22.04.3-live-server-amd64.iso"
}

variable "network_bridge" {
  description = "Bridge de red a utilizar"
  type        = string
  default     = "vmbr0"
}
