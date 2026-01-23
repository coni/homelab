terraform {
  backend "pg" {}
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = ">= 0.93.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = "5.6.0" # OpenBao is compatible with the Vault provider
    }
  }
}


provider "proxmox" {
  insecure = true
  ssh {
    agent    = true
    username = "root"
  }
}

provider "vault" {
}
