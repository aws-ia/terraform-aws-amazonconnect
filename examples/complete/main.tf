data "aws_caller_identity" "current" {}

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

  # Instance Storage Configuration
  instance_storage_configs = local.instance_storage_configs

  # Hours of Operations
  hours_of_operations = local.hours_of_operations
  hours_of_operations_tags = {
    example = "foo"
  }

  # Contact Flows / Modules
  contact_flows = local.contact_flows

  # Queues
  queues = local.queues

  # Quick Connects
  quick_connects = local.quick_connects

  # Routing / Security Profiles
  routing_profiles  = local.routing_profiles
  security_profiles = local.security_profiles

  # Vocabularies
  vocabularies = local.vocabularies

  # Lex Bot / Lambda Function Associations
  bot_associations             = local.bot_associations
  lambda_function_associations = local.lambda_function_associations

  # Users / Hierarchy Group / Structure
  users                    = local.users
  user_hierarchy_groups    = local.user_hierarchy_groups
  user_hierarchy_structure = local.user_hierarchy_structure

  # Tags
  tags = {
    example1 = "bar"
    example2 = "baz"
  }
}

module "amazon_connect_parent_group" {
  source = "../../"

  create_instance = false
  instance_id     = module.amazon_connect.instance.id

  # Parent Hierarchy Group
  user_hierarchy_groups = {
    parent = {}
  }
}
