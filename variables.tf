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
    type = string
}

variable "node_name" {
    description = "Nombre del nodo donde vive la vm"
    type = string
    default = "dunwitch"
}

variable "testing" {
  type = object({
    name      = string
    memory    = number
    id        = number
    cores     = number
    disk_size = number
  })
}