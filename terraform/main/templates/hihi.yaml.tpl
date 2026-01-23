#cloud-config
hostname: ${hostname}
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
  - ufw
  - acl
  - curl
  - jq

write_files:
  - path: /etc/sysctl.d/10-unprivileged-ports.conf
    content: |
      net.ipv4.ip_unprivileged_port_start=9000

  # ============================================================================
  # DYNAMIC SECRET FETCHING LOOP
  # This generates a unique fetch script for EVERY service assigned to this VM
  # ============================================================================
  %{ for service_name, config in secrets }

  # 1. Write the Golden Ticket files specifically for this service
  - path: /etc/openbao/${service_name}_wrapping_token
    permissions: '0600'
    owner: root:root
    content: "${config.bao_wrapping_token}"

  - path: /etc/openbao/${service_name}_role_id
    permissions: '0600'
    owner: root:root
    content: "${config.bao_role_id}"

  # 2. The Fetch Script for this service
  - path: /usr/local/bin/fetch-${service_name}-secrets.sh
    permissions: '0700'
    owner: root:root
    content: |
      #!/bin/bash
      set -e
      export VAULT_ADDR="${config.bao_addr}"

      # Dynamic paths based on service name
      SECRET_DIR="/run/${service_name}"
      SECRET_FILE="$SECRET_DIR/secrets.env"
      WRAP_TOKEN_FILE="/etc/openbao/${service_name}_wrapping_token"
      ROLE_ID_FILE="/etc/openbao/${service_name}_role_id"

      mkdir -p $SECRET_DIR

      if [ -f "$WRAP_TOKEN_FILE" ]; then
        echo "Found wrapping token for ${service_name}..."
        WRAP_TOKEN=$(cat "$WRAP_TOKEN_FILE")

        # --- UNWRAP ---
        UNWRAP_RESPONSE=$(curl -s --fail --header "X-Vault-Token: $WRAP_TOKEN" \
          --request POST $VAULT_ADDR/v1/sys/wrapping/unwrap)
        SECRET_ID=$(echo "$UNWRAP_RESPONSE" | jq -r .data.secret_id)

        if [ "$SECRET_ID" == "null" ] || [ -z "$SECRET_ID" ]; then
           echo "Error: Failed to unwrap ${service_name} token."
           exit 1
        fi

        # Burn ticket
        rm -f "$WRAP_TOKEN_FILE"

        # --- LOGIN ---
        ROLE_ID=$(cat "$ROLE_ID_FILE")
        LOGIN_PAYLOAD=$(jq -n --arg rid "$ROLE_ID" --arg sid "$SECRET_ID" '{"role_id": $rid, "secret_id": $sid}')
        CLIENT_TOKEN=$(curl -s --fail --request POST \
          --data "$LOGIN_PAYLOAD" \
          $VAULT_ADDR/v1/auth/approle/login | jq -r '.auth.client_token')

        # --- FETCH ---
        # Note: We use the 'secret_path' passed from Terraform
        SECRETS_JSON=$(curl -s --fail --header "X-Vault-Token: $CLIENT_TOKEN" \
          $VAULT_ADDR/v1/${config.secret_path})

        echo "$SECRETS_JSON" | jq -r '.data.data | to_entries | .[] | .key + "=" + .value' > $SECRET_FILE

        # --- PERMISSIONS ---
        chown -R debian:debian $SECRET_DIR
        chmod 0600 $SECRET_FILE
        echo "Secrets injected for ${service_name}"
      fi

  # 3. Systemd Service to run the fetcher
  - path: /etc/systemd/system/fetch-${service_name}-secrets.service
    permissions: '0644'
    content: |
      [Unit]
      Description=Fetch ${service_name} Secrets
      Before=user@1000.service
      After=network-online.target
      Wants=network-online.target

      [Service]
      Type=oneshot
      ExecStart=/usr/local/bin/fetch-${service_name}-secrets.sh
      RemainAfterExit=yes

      [Install]
      WantedBy=multi-user.target
  %{ endfor }

mounts:
  - [ "${hostname}-shared", "/home/debian/.config/containers/", "virtiofs", "rw,relatime", "0", "0" ]

runcmd:
  - sysctl --system
  - systemctl daemon-reload

  # Loop again to enable all the services we just created
  %{ for service_name, config in secrets }
  - systemctl enable --now fetch-${service_name}-secrets.service
  %{ endfor }

  - ufw default allow incoming
  - ufw default allow outgoing
  - ufw allow 9000/tcp
  - ufw allow 9443/tcp
  - ufw --force enable

  - chown -R debian:debian /home/debian/
  - loginctl enable-linger debian
  - machinectl shell debian@.host /usr/bin/systemctl --user daemon-reload
  - machinectl shell debian@.host /usr/bin/systemctl --user enable --now podman.socket
