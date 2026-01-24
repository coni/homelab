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
resource "vault_approle_auth_backend_role" "authentik" {
  backend        = vault_auth_backend.approle.path
  role_name      = "authentik-server"
  token_policies = [vault_policy.authentik_policy.name]

  token_ttl      = 3600  # Token lives for 1 hour
  token_max_ttl  = 14400 # Max 4 hours
  secret_id_ttl  = 600   # The "login password" (SecretID) is valid for 10 mins
}

resource "vault_approle_auth_backend_role_secret_id" "authentik_id" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.authentik.role_name
  wrapping_ttl = "300s"
}

# ----------------  POLICY
resource "vault_policy" "authentik_policy" {
  name = "authentik-policy"
  policy = <<EOT
path "secret/data/authentik/config" {
  capabilities = ["read"]
}
EOT
}

# ----------------  SECRETS DEFINITION
resource "random_id" "authentik_secret_key" {
  byte_length = 59
}

resource "random_password" "authentik_db_password" {
  length           = 35
  special          = false
  #override_special = "_-"
}

# ----------------  PAYLOAD FOR VALUES TO PUT IN OPENBAO
resource "vault_kv_secret_v2" "authentik_config" {
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

############################  --PTERODACTYL--  ############################

# ----------------  APPROLE / TOKEN
resource "vault_approle_auth_backend_role" "pterodactyl" {
  backend        = vault_auth_backend.approle.path
  role_name      = "pterodactyl-server"
  token_policies = [vault_policy.pterodactyl_policy.name]

  token_ttl      = 3600  # Token lives for 1 hour
  token_max_ttl  = 14400 # Max 4 hours
  secret_id_ttl  = 600   # The "login password" (SecretID) is valid for 10 mins
}

resource "vault_approle_auth_backend_role_secret_id" "pterodactyl_id" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.pterodactyl.role_name
  wrapping_ttl = "300s"
}

# ----------------  POLICY
resource "vault_policy" "pterodactyl_policy" {
  name = "pterodactyl-policy"
  policy = <<EOT
path "secret/data/pterodactyl/config" {
  capabilities = ["read"]
}
EOT
}

# ----------------  SECRETS DEFINITION
resource "random_password" "pterodactyl_sql_pass"     { length = 31 }
resource "random_password" "pterodactyl_sql_root_pass" { length = 31 }


# ----------------  PAYLOAD FOR VALUES TO PUT IN OPENBAO
resource "vault_kv_secret_v2" "pterodactyl_config" {
  mount               = vault_mount.kv.path
  name                = "pterodactyl/config"
  cas                 = 1
  delete_all_versions = true

  data_json = jsonencode({

    DB_PASSORD          = random_password.pterodactyl_sql_pass.result
    MYSQL_PASSWORD      = random_password.pterodactyl_sql_pass.result
    MYSQL_ROOT_PASSWORD = random_password.pterodactyl_sql_root_pass.result
    APP_URL             = "pterodactyl.local.ni-coni-coni.com"
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
    pterodactyl = {
      bao_role_id = vault_approle_auth_backend_role.pterodactyl.role_id
      bao_wrapping_token = vault_approle_auth_backend_role_secret_id.pterodactyl_id.wrapping_token
      bao_addr = var.bao_addr
      secret_path        = "secret/data/pterodactyl/config"
    }
  }
}
