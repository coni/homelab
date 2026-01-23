node_name          = "XXX"
bao_addr           = "XXX"
snippets_datastore = "XXX"
ssh-key            = "XXX"

vms = {
  "miambao" = {
    vm_id     = 600
    cores     = 2
    memory    = 4096
    disk_size = 10
    host_path = "/bewitched-raidz2/server/miambao/"
    networks = [
      { bridge = "vmbr0" },
      { bridge = "bao" }
    ]
    ips = [
      { address = "192.168.1.201/24", gateway = "192.168.1.254" },
      { address = "10.0.1.1/24" }
    ]
  },
  "main-proxy" = {
    vm_id     = 601
    cores     = 2
    memory    = 4096
    disk_size = 10
    host_path = "/bewitched-raidz2/server/main-proxy/"
    networks = [
      { bridge = "vmbr0" },
      { bridge = "vmbr1" },
      { bridge = "bao" }
    ]
    ips = [
      { address = "192.168.1.198/24", gateway = "192.168.1.254" },
      { address = "10.0.0.5/24" },
      { address = "10.0.1.2/24" }
    ]
  }
}
