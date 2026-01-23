resource "proxmox_virtual_environment_network_linux_bridge" "internal_network" {
  node_name = var.node_name
  name      = "bao"
  comment   = "Bao Private Network"
}
