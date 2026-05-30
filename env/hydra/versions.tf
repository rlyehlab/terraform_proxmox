terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.86.0"
    }
  }
  backend "s3" {
    bucket  = "rlab-tfstate"
    key     = "proxmox/hydra/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
