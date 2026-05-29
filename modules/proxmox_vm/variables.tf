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

variable "template_map" {
  type = map(number)
  default = {
    ubuntu = 6009
    debian = 6010
  }
}

variable "template_name" {
  type    = string
  default = "ubuntu"
}

variable "on_boot" {
  type    = bool
  default = true
}

variable "started" {
  type    = bool
  default = true
}
