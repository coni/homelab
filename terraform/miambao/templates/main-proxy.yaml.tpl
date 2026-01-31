#cloud-config

hostname: main-proxy
ssh_authorized_keys:
  - ssh-rsa ${ssh-key}
ssh_pwauth: false

users:
  - name: debian
    sudo: []
    groups: [users]
    ssh_authorized_keys:
      - ssh-rsa ${ssh-key}

package_update: true
package_upgrade: true
packages:
  - podman
  - systemd-container
  - uidmap 
  - dbus-user-session
  - ufw               # Uncomplicated Firewall

write_files:
  - path: /etc/sysctl.d/10-unprivileged-ports.conf
    content: |
      net.ipv4.ip_unprivileged_port_start=80

  - path: /etc/hosts
    content: |
      10.0.1.1      miambao.local
    append: true

mounts:
  - [ "main-proxy-shared", "/home/debian/.config/containers/", "virtiofs", "rw,relatime", "0", "0" ]

runcmd:
  - sysctl --system

  - ufw default allow incoming
  - ufw default allow outgoing
  - ufw allow 80/tcp
  - ufw allow 443/tcp
  - ufw --force enable

  - chown -R debian:debian /home/debian/

  - loginctl enable-linger debian
  - machinectl shell debian@.host /usr/bin/podman build -t caddy-porkbun /home/debian/.config/containers/image/caddy-porkbun
  - machinectl shell debian@.host /usr/bin/systemctl --user daemon-reload
  - machinectl shell debian@.host /usr/bin/systemctl --user enable --now podman.socket
