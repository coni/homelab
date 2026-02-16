resource "proxmox_virtual_environment_network_linux_bridge" "bao_network" {
  node_name = var.node_name
  name      = "bao"
  comment   = "Bao Private Network"
}

resource "proxmox_virtual_environment_network_linux_bridge" "nextcloud_network" {
  node_name = var.node_name
  name      = "nextcloud"
  comment   = "Nextcloud Private Network"
}
