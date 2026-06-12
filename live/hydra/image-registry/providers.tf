terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    region = "us-east-1"
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.86.0"
    }
  }
}

locals {
  proxmox_ssh_host = split(":", trimprefix(var.proxmox_api_url, "https://"))[0]
}

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = var.proxmox_api_token
  username  = "tf@pve"
  password  = var.password
  insecure  = true

  ssh {
    username = var.proxmox_ssh_username
    agent    = var.proxmox_ssh_password == ""
    password = var.proxmox_ssh_password != "" ? var.proxmox_ssh_password : null

    node {
      name    = var.node_name
      address = local.proxmox_ssh_host
    }
  }
}
