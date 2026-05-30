provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = var.proxmox_api_token
  username  = "tf@pve"
  password  = var.password
  insecure  = true

  ssh {
    agent    = true
    username = "tf"
  }

}
