resource "vault_mount" "kv" {
  path        = "secret"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine"
}

resource "vault_auth_backend" "approle" {
  type = "approle"
}

############################  --AUTHENTIK--  ############################

# ----------------  APPROLE / TOKEN
data "vault_approle_auth_backend_role" "authentik" {
  backend        = vault_auth_backend.approle.path
  role_name      = "authentik-server"
  token_policies = [vault_policy.authentik_policy.name]

  token_ttl      = 3600  # Token lives for 1 hour
  token_max_ttl  = 14400 # Max 4 hours
  secret_id_ttl  = 600   # The "login password" (SecretID) is valid for 10 mins
}

data "vault_approle_auth_backend_role_secret_id" "authentik_id" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.authentik.role_name
  wrapping_ttl = "300s"
}

# ----------------  POLICY
data "vault_policy" "authentik_policy" {
  name = "authentik-policy"
  policy = <<EOT
path "secret/data/authentik/config" {
  capabilities = ["read"]
}
EOT
}

# ----------------  SECRETS DEFINITION
data "random_id" "authentik_secret_key" {
  byte_length = 59
}

data "random_password" "authentik_db_password" {
  length           = 35
  special          = false
  #override_special = "_-"
}

# ----------------  PAYLOAD FOR VALUES TO PUT IN OPENBAO
data "vault_kv_secret_v2" "authentik_config" {
  mount               = vault_mount.kv.path
  name                = "authentik/config"
  cas                 = 1
  delete_all_versions = true

  data_json = jsonencode({
    AUTHENTIK_POSTGRESQL__HOST = "postgresql"
    AUTHENTIK_POSTGRESQL__NAME = "authentik"
    AUTHENTIK_POSTGRESQL__USER = "authentik"

    AUTHENTIK_POSTGRESQL__PASSWORD = random_password.authentik_db_password.result
    AUTHENTIK_SECRET_KEY           = random_id.authentik_secret_key.b64_std

    POSTGRES_DB                    = "authentik" 
    POSTGRES_USER                  = "authentik" 
    POSTGRES_PASSWORD              = random_password.authentik_db_password.result
  })
}

############################  --nextcloud--  ############################

# ----------------  APPROLE / TOKEN
data "vault_approle_auth_backend_role" "nextcloud" {
  backend        = vault_auth_backend.approle.path
  role_name      = "nextcloud-server"
  token_policies = [vault_policy.nextcloud_policy.name]

  token_ttl      = 3600  # Token lives for 1 hour
  token_max_ttl  = 14400 # Max 4 hours
  secret_id_ttl  = 600   # The "login password" (SecretID) is valid for 10 mins
}

data "vault_approle_auth_backend_role_secret_id" "nextcloud_id" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.nextcloud.role_name
  wrapping_ttl = "300s"
}

# ----------------  POLICY
data "vault_policy" "nextcloud_policy" {
  name = "nextcloud-policy"
  policy = <<EOT
path "secret/data/nextcloud/config" {
  capabilities = ["read"]
}
EOT
}

# ----------------  SECRETS DEFINITION
data "random_password" "nextcloud_db_password" {
  length           = 35
  special          = false
  #override_special = "_-"
}

data "random_password" "nextcloud_root_password" {
  length           = 35
  special          = false
  #override_special = "_-"
}

# ----------------  PAYLOAD FOR VALUES TO PUT IN OPENBAO
data "vault_kv_secret_v2" "nextcloud_config" {
  mount               = vault_mount.kv.path
  name                = "nextcloud/config"
  cas                 = 1
  delete_all_versions = true

  data_json = jsonencode({
    MYSQL_ROOT_PASSWORD        = random_password.nextcloud_root_password.result
    MYSQL_PASSWORD             = random_password.nextcloud_db_password.result
    MYSQL_DATABASE             = "nextcloud"
    MYSQL_USER                 = "nextcloud"
  })
}

###########################  --pterodactyl_panel--  ###########################

## ----------------  APPROLE / TOKEN
data "vault_approle_auth_backend_role" "pterodactyl_panel" {
  backend        = vault_auth_backend.approle.path
  role_name      = "pterodactyl_panel"
  token_policies = [vault_policy.pterodactyl_panel_policy.name]

  token_ttl      = 3600  # Token lives for 1 hour
  token_max_ttl  = 14400 # Max 4 hours
  secret_id_ttl  = 600   # The "login password" (SecretID) is valid for 10 mins
}

data "vault_approle_auth_backend_role_secret_id" "pterodactyl_panel_id" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.pterodactyl_panel.role_name
  wrapping_ttl = "300s"
}

# ----------------  POLICY
data "vault_policy" "pterodactyl_panel_policy" {
  name = "pterodactyl_panel-policy"
  policy = <<EOT
path "secret/data/pterodactyl_panel/config" {
  capabilities = ["read"]
}
EOT
}

# ----------------  SECRETS DEFINITION
data "random_password" "pterodactyl_panel_db_password" {
  length           = 35
  special          = false
  #override_special = "_-"
}

data "random_password" "pterodactyl_panel_root_password" {
  length           = 35
  special          = false
  #override_special = "_-"
}

# ----------------  PAYLOAD FOR VALUES TO PUT IN OPENBAO
data "vault_kv_secret_v2" "pterodactyl_panel_config" {
  mount               = vault_mount.kv.path
  name                = "pterodactyl_panel/config"
  cas                 = 1
  delete_all_versions = true

  data_json = jsonencode({
    MYSQL_ROOT_PASSWORD = random_password.pterodactyl_panel_root_password.result
    MYSQL_PASSWORD      = random_password.pterodactyl_panel_db_password.result
    DB_PASSWORD         = random_password.pterodactyl_panel_db_password.result
  })
}

##############################   PUT GOLDEN TICKET TOKENS HERE FOR CLOUDINIT
locals {
  all_secrets = {
    authentik = {
      bao_role_id = vault_approle_auth_backend_role.authentik.role_id
      bao_wrapping_token = vault_approle_auth_backend_role_secret_id.authentik_id.wrapping_token
      bao_addr = var.bao_addr
      secret_path        = "secret/data/authentik/config"
    },
    nextcloud = {
      bao_role_id = vault_approle_auth_backend_role.nextcloud.role_id
      bao_wrapping_token = vault_approle_auth_backend_role_secret_id.nextcloud_id.wrapping_token
      bao_addr = var.bao_addr
      secret_path        = "secret/data/nextcloud/config"
    },
    pterodactyl_panel = {
      bao_role_id = vault_approle_auth_backend_role.pterodactyl_panel.role_id
      bao_wrapping_token = vault_approle_auth_backend_role_secret_id.pterodactyl_panel_id.wrapping_token
      bao_addr = var.bao_addr
      secret_path        = "secret/data/pterodactyl_panel/config"
    }
  }
}
