data "aws_connect_queue" "example" {
  instance_id = module.amazon_connect.instance.id
  name        = "BasicQueue"
}

resource "random_string" "instance_alias" {
  length  = 32
  special = false
  numeric = false
  upper   = false
}

module "amazon_connect" {
  # source  = "aws-ia/amazonconnect/aws"
  # version = ">= 0.0.1"

  source = "../../"

  # Instance
  instance_alias                     = random_string.instance_alias.result
  instance_identity_management_type  = "CONNECT_MANAGED"
  instance_inbound_calls_enabled     = true
  instance_outbound_calls_enabled    = true
  instance_contact_flow_logs_enabled = true

  # Contact Flows / Modules
  contact_flows        = local.contact_flows
  contact_flow_modules = local.contact_flow_modules

  # Quick Connects
  quick_connects = local.quick_connects

  # Routing / Security Profiles
  routing_profiles  = local.routing_profiles
  security_profiles = local.security_profiles

  # Lambda Function Associations
  lambda_function_associations = local.lambda_function_associations

  # Users / Hierarchy Group / Structure
  users = local.users
}
