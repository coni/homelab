node_name           = "bewitched"
snippets_datastore  = "ci-snippets"
ssh-key             = "AAAAB3NzaC1yc2EAAAADAQABAAABgQDIZXSitm2BswxkmzKKFmuuRdmsIDPGwheW7ecCwPcLvnhTVswQMX6xdl4/7X0Ro7odJwgalsl4Mohs8f15IW0QpcDq75U/kGgLK5ml3Y9X4jTC8anSEnIyj2WqVqWQoTSNuDZSIb4Q88uw45QQ+qG0KjQ1PgP0W63DWjb+L7XV7HtlWiMuCTMGAmBkjBgWzdB5VjLj5Jn8omDWGIKpPGr24k+Ts6YBx6nYkrcLpiMS4AQVGgzM/C/BLpM6V8PX934I5U8ZlwuzzP+I6Y1bofmy3rb+AxhfD2EdzGKQ+TvjNa0UsholSpMYu4DLe/vW0wCVuJ9i+58MBUWZ1sq36VhlwkJjS2HXUO+V3dWd3+2vd1vQwBedeIsd0EfS2Gzy9YVztBOLRDJKyLp5znJw8EgXvF/1/mEMhGiE2VrLAq1VyAEoMfPIBufFnqI/UTnKpEsZ7uRWBrWPxg5umx0/jedoQF5hXfVj8jFW19ieZMGpdcaxiNq/WECI3TKDfvqnsuM= coni@lin"

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
