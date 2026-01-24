node_name           = "bewitched"
bao_addr            = "https://bao.local.ni-coni-coni.com"
snippets_datastore  = "ci-snippets"
ssh-key             = "AAAAB3NzaC1yc2EAAAADAQABAAABgQDIZXSitm2BswxkmzKKFmuuRdmsIDPGwheW7ecCwPcLvnhTVswQMX6xdl4/7X0Ro7odJwgalsl4Mohs8f15IW0QpcDq75U/kGgLK5ml3Y9X4jTC8anSEnIyj2WqVqWQoTSNuDZSIb4Q88uw45QQ+qG0KjQ1PgP0W63DWjb+L7XV7HtlWiMuCTMGAmBkjBgWzdB5VjLj5Jn8omDWGIKpPGr24k+Ts6YBx6nYkrcLpiMS4AQVGgzM/C/BLpM6V8PX934I5U8ZlwuzzP+I6Y1bofmy3rb+AxhfD2EdzGKQ+TvjNa0UsholSpMYu4DLe/vW0wCVuJ9i+58MBUWZ1sq36VhlwkJjS2HXUO+V3dWd3+2vd1vQwBedeIsd0EfS2Gzy9YVztBOLRDJKyLp5znJw8EgXvF/1/mEMhGiE2VrLAq1VyAEoMfPIBufFnqI/UTnKpEsZ7uRWBrWPxg5umx0/jedoQF5hXfVj8jFW19ieZMGpdcaxiNq/WECI3TKDfvqnsuM= coni@lin"

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
  },
  "game-server" = {
    vm_id     = 501
    cores     = 2
    memory    = 16384
    disk_size = 20
    host_path = "/bewitched-raidz2/server/game-server/"
    networks = [
      { bridge = "vmbr0" },
    ]
    ips = [
      { address = "192.168.1.190/24", gateway = "192.168.1.254" },
    ],
    services  = ["pterodactyl"]
  }
}

