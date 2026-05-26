# Variables de autenticación
# variable "proxmox_api_url" {
#   description = "URL de la API de Proxmox"
#   type        = string
#   sensitive   = true
# }
# variable "proxmox_api_token" {
#   description = "id=secret"
#   type        = string
#   sensitive   = true
# }
variable "password" {
  description = "user password "
  type        = string
  sensitive   = false
}
variable "proxmox_node_name" {
  description = "Nodo de Proxmox donde crear la VM"
  type        = string
}
variable "vm_name" {
  description = "nombre de la vm a generar"
  type        = string
}

variable "memory" {
  description = "Memoria RAM asignada a la VM"
  type = number
  default = 2096
}

variable "vm_id" {
  description = "ID de la máquina virtual"
  type        = number
}

variable "cores" {
  description = "Amount of dedicated cpu cores"
  type        = number
  default     = 2
}

variable "datastore_id" {
  description = "Node disk ID"
  type        = string
  default     = "local-lvm"
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 16
}