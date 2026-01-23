#cloud-config

hostname: miambao
ssh_authorized_keys:
  - ssh-rsa ${ssh-key}
ssh_pwauth: false

users:
  - default

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
mounts:
  - [ "miambao-shared", "/home/debian/.config/containers/", "virtiofs", "rw,relatime", "0", "0" ]

runcmd:
  - sysctl --system
  - ufw default allow incoming
  - ufw default allow outgoing
  - ufw allow 80/tcp
  - ufw allow 443/tcp

  - ufw --force enable
  - chown -R debian:debian /home/debian/

  - loginctl enable-linger debian

  - machinectl shell debian@.host /usr/bin/systemctl --user daemon-reload
