terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = ">= 0.93.0"
    }
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  node_name   = var.node_name
  name        = var.vm_name
  description = var.description
  vm_id       = var.vm_id

  cpu {
    cores = var.cpu_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory
    floating  = var.memory / 2
  }

  disk {
    datastore_id = var.datastore_id
    file_id      = var.iso_file_id
    interface    = "scsi0"
    size         = var.disk_size
  }

  virtiofs {
    mapping   = var.virtiofs_mapping
    cache     = "always"
    direct_io = true
  }

  operating_system {
    type = "l26"
  }

  dynamic "network_device" {
    for_each = var.network_interfaces
    content {
      bridge = network_device.value.bridge
    }
  }

  initialization {
    user_data_file_id = var.ci_user_data_id
    datastore_id      = var.datastore_id

    dns {
      servers = ["8.8.8.8", "1.1.1.1"] # Your DNS Server (AdGuard/PiHole?)
    }
    dynamic "ip_config" {
      for_each = var.ip_configs
      content {
        ipv4 {
          address = ip_config.value.address
          gateway = ip_config.value.gateway
        }
      }
    }
  }
}
