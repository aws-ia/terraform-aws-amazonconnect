# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

################################################################################
# Instance
################################################################################
output "instance" {
  description = "Full output attributes of aws_connect_instance resource."
  value       = one(aws_connect_instance.this[*])
}

output "instance_id" {
  description = "Amazon Connect instance ID. If create_instance = false, var.instance_id is returned."
  value       = local.instance_id
}

################################################################################
# Instance Storage Config
################################################################################
output "instance_storage_configs" {
  description = "Full output attributes of aws_connect_instance_storage_config resource(s)."
  value       = aws_connect_instance_storage_config.this
}

################################################################################
# Hours of Operation
################################################################################
output "hours_of_operations" {
  description = "Full output attributes of aws_connect_hours_of_operation resource(s)."
  value       = aws_connect_hours_of_operation.this
}

################################################################################
# Contact Flow / Module
################################################################################
output "contact_flows" {
  description = "Full output attributes of aws_connect_contact_flow resource(s)."
  value       = aws_connect_contact_flow.this
}

output "contact_flow_modules" {
  description = "Full output attributes of aws_connect_contact_flow_module resource(s)."
  value       = aws_connect_contact_flow_module.this
}

################################################################################
# Queue
################################################################################
output "queues" {
  description = "Full output attributes of aws_connect_queue resource(s)."
  value       = aws_connect_queue.this
}

################################################################################
# Quick Connect
################################################################################
output "quick_connects" {
  description = "Full output attributes of aws_connect_quick_connect resource(s)."
  value       = aws_connect_quick_connect.this
}

################################################################################
# Routing / Security Profiles
################################################################################
output "routing_profiles" {
  description = "Full output attributes of aws_connect_routing_profile resource(s)."
  value       = aws_connect_routing_profile.this
}

output "security_profiles" {
  description = "Full output attributes of aws_connect_security_profile resource(s)."
  value       = aws_connect_security_profile.this
}

################################################################################
# Vocabulary
################################################################################
output "vocabularies" {
  description = "Full output attributes of aws_connect_vocabulary resource(s)."
  value       = aws_connect_vocabulary.this
}

################################################################################
# Lex Bot / Lambda Function Associations
################################################################################
output "bot_associations" {
  description = "Full output attributes of aws_connect_bot_association resource(s)."
  value       = aws_connect_bot_association.this
}

output "lambda_function_associations" {
  description = "Full output attributes of aws_connect_lambda_function_association resource(s)."
  value       = aws_connect_lambda_function_association.this
}

################################################################################
# Users / Hierarchy Group / Structure
################################################################################
output "users" {
  description = "Full output attributes of aws_connect_user resource(s)."
  value       = aws_connect_user.this
  sensitive   = true
}

output "user_hierarchy_groups" {
  description = "Full output attributes of aws_connect_user_hierarchy_group resource(s)."
  value       = aws_connect_user_hierarchy_group.this
}

output "user_hierarchy_structure" {
  description = "Full output attributes of aws_connect_user_hierarchy_structure resource(s)."
  value       = one(aws_connect_user_hierarchy_structure.this[*])
}
