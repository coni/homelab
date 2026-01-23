variable "node_name" {}
variable "vm_name" {}
variable "vm_id" {}
variable "description" { default = "Managed by Terraform" }
variable "cpu_cores" { default = 2 }
variable "memory" { default = 4096 }
variable "disk_size" { default = 10 }
variable "datastore_id" { default = "local-lvm" }
variable "iso_file_id" {}
variable "virtiofs_mapping" {}
variable "ci_user_data_id" {}

variable "network_interfaces" {
  type = list(object({
    bridge = string
  }))
}

variable "ip_configs" {
  type = list(object({
    address = string
    gateway = optional(string)
  }))
}
