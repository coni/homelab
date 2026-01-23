node_name          = "XXX"
bao_addr           = "XXX"
snippets_datastore = "XXX"
ssh-key            = "XXX"

vms = {
  "hihi" = {
    vm_id     = 500
    cores     = 2
    memory    = 4096
    disk_size = 10
    host_path = "/bewitched-raidz2/server/hihi/"
    networks = [
      { bridge = "vmbr0" },
    ]
    ips = [
      { address = "192.168.1.197/24", gateway = "192.168.1.254" },
    ],
    services  = ["authentik"]
  }
}

