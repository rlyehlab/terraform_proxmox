provider "proxmox" {
  # Configuración mediante variables de entorno
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret

  # Opciones adicionales (opcionales)
  pm_tls_insecure = var.proxmox_tls_insecure
  pm_debug        = var.proxmox_debug
  pm_log_enable   = true
  pm_log_file     = "terraform-plugin-proxmox.log"
  pm_timeout      = 3600
}

