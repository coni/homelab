resource "proxmox_virtual_environment_download_file" "debian-trixie-13-img" {
  content_type = "iso"
  datastore_id = "local"
  node_name   = var.node_name
  url          = "https://cloud.debian.org/images/cloud/trixie/daily/latest/debian-13-generic-amd64-daily.qcow2"
  file_name    = "debian-13-generic-amd64-daily.img"
}
