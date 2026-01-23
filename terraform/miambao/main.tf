module "virtual_machines" {
  source   = "./modules/debian-vm"
  for_each = var.vms

  node_name = var.node_name
  vm_name   = each.key
  vm_id     = each.value.vm_id
 
  cpu_cores = each.value.cores
  memory    = each.value.memory
  disk_size = each.value.disk_size

  iso_file_id = proxmox_virtual_environment_download_file.debian-trixie-13-img.id
  virtiofs_mapping = proxmox_virtual_environment_hardware_mapping_dir.vm_mappings[each.key].name

  ci_user_data_id  = "${var.snippets_datastore}:snippets/${each.key}.yaml"

  network_interfaces = each.value.networks
  ip_configs         = each.value.ips
}

resource "proxmox_virtual_environment_hardware_mapping_dir" "vm_mappings" {
  for_each = var.vms
  name = "${each.key}-shared"
  map = [{
    node = var.node_name
    path = each.value.host_path
  }]
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  for_each     = var.vms
  content_type = "snippets"
  datastore_id = var.snippets_datastore
  node_name    = var.node_name

  source_raw {
    file_name = "${each.key}.yaml"
    data      = templatefile("${path.module}/templates/${each.key}.yaml.tpl", {

      ssh-key  = var.ssh-key
      hostname = each.key
    })
  }
}

