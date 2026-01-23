variable "node_name" { type = string }
variable "snippets_datastore"  { type = string }
variable "ssh-key" { type = string }

variable "vms" {
  type = map(object({
    vm_id     = number
    cores     = number
    memory    = number
    disk_size = number
    host_path = string
    networks  = list(object({ bridge = string }))
    ips       = list(object({ address = string, gateway = optional(string) }))
  }))
}

