# Variables de autenticación
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
  default     = "testing"
}
variable "vm_id" {
  description = "ID de la máquina virtual"
  type        = number
  default     = 200
}

#variable "proxmox_tls_insecure" {
#  description = "Si se debe aceptar certificados TLS no verificados"
#  type        = bool
#  default     = true
#}
#
#variable "template_name" {
#  default = "ubuntu-noble-template"
#  type    = string
#}
## Variables para la VM
#variable "vm_name" {
#  description = "Nombre de la máquina virtual"
#  type        = string
#  default     = "testing"
#}
#
#variable "vm_cores" {
#  description = "Número de cores de la VM"
#  type        = number
#  default     = 2
#}
#
#variable "vm_memory" {
#  description = "Memoria en MB para la VM"
#  type        = number
#  default     = 2048
#}
#
#variable "vm_disk_size" {
#  description = "Tamaño del disco en GB"
#  type        = string
#  default     = "20G"
#}
#
#variable "vm_storage" {
#  description = "Almacenamiento donde crear el disco"
#  type        = string
#  default     = "local-lvm"
#}
#
#variable "network_bridge" {
#  description = "Bridge de red a utilizar"
#  type        = string
#  default     = "vmbr0"
#}
#variable "ssh_key" {
#  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCGeLU9MtiXkJkNIP1ZEU/bbnPD3yB80w0yA4PxEvdih8nqWLHO/4jO4wSi3gDN/AwDAPry6AeY401bgdnP0y8pG63xMQyx/qS2yp4089mUJ37jorG8CEge1WObk2e3Sm0dux+c2SI3vKNN1y3sq1vhmFg4QkvgnIfb9p9KX1lvGjhfT1piR7OORaHR15GVcS1Yu5a1d6UzPr+5E1j/oT+amloeInjlLqneRK1PwDz46oSj90QAnv8pXuu5YvzYlKp+B3Dk0j+CWQ6cSY0T0PgTvBdRGXMzjZNfQZQX67a1Ave7hYC2PWB9UqmFMUvfh5XZMs21CzfHIWDoys/f1KH1/JykL/Q/5aYh9OhNATtdLs79O96ZLu1A0Ltlt6vaDfy+1T2FtCLQVmIqsczdvFZKi6aD+jgTTEZ/KrSNykm93VvwfCBQZyASYtM3HNPwRZPWtSj2KfA8XlixxGyBnyjb5KHwAm3YaXzId1m5kzNBdQ8kcWBHgMpLAref9KcBawjXzV2Yh4BdHceWe/e8+083oFnolfIWvLXyxtPNb3qUf0Ri8rMJN2nwOjcQ/SFQTme8CEDllvisZWGY0BIjO7HTXXXa+nAlMCgk1a/16duds1yTXEZ+olCB5zM2fsuu5tY7bLUR0YbqjEzkW1jm5/f0beEP2cvWLkzdrgeNSYT5lw== caripa.front@gmail.com"
#}
