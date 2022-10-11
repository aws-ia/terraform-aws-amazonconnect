resource "random_string" "instance_alias" {
  length  = 32
  special = false
  numeric = false
  upper   = false
}

module "amazon_connect" {
  source = "../../"

  instance_identity_management_type = "CONNECT_MANAGED"
  instance_inbound_calls_enabled    = true
  instance_outbound_calls_enabled   = true
  instance_alias                    = random_string.instance_alias.result
}
