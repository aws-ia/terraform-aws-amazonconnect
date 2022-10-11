# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

################################################################################
# Instance
################################################################################
# required (when create_instance = true)
variable "instance_identity_management_type" {
  type        = string
  default     = null
  description = "Specifies the identity management type attached to the instance. Allowed values are: SAML, CONNECT_MANAGED, EXISTING_DIRECTORY."
}

variable "instance_inbound_calls_enabled" {
  type        = bool
  default     = null
  description = "Specifies whether inbound calls are enabled."
}

variable "instance_outbound_calls_enabled" {
  type        = bool
  default     = null
  description = "Specifies whether outbound calls are enabled."
}

# optional
variable "create_instance" {
  type        = bool
  default     = true
  description = "Controls if the aws_connect_instance resource should be created. Defaults to true."
}

variable "instance_id" {
  type        = string
  default     = null
  description = "If create_instance is set to false, you may still create other resources and pass in an instance ID that was created outside this module. Ignored if create_instance is true."
}

variable "instance_auto_resolve_best_voices_enabled" {
  type        = bool
  default     = null
  description = "Specifies whether auto resolve best voices is enabled. Defaults to true."
}

variable "instance_contact_flow_logs_enabled" {
  type        = bool
  default     = null
  description = "Specifies whether contact flow logs are enabled. Defaults to false."
}

variable "instance_contact_lens_enabled" {
  type        = bool
  default     = null
  description = "Specifies whether contact lens is enabled. Defaults to true."
}

variable "instance_directory_id" {
  type        = string
  default     = null
  description = "The identifier for the directory if instance_identity_management_type is EXISTING_DIRECTORY."
}

variable "instance_early_media_enabled" {
  type        = bool
  default     = null
  description = "Specifies whether early media for outbound calls is enabled. Defaults to true if instance_outbound_calls_enabled is true."
}

variable "instance_alias" {
  type        = string
  default     = null
  description = "Specifies the name of the instance. Required if instance_directory_id not specified."
}

################################################################################
# Instance Storage Config
################################################################################
variable "instance_storage_configs" {
  type        = any
  default     = {}
  description = <<-EOF
A map of Amazon Connect Instance Storage Configs.

The key of the map is the Instance Storage Config `resource_type`. The value is the configuration for that Instance Storage Config, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_instance_storage_config#storage_config) (except `resource_type` which is the key, and `instance_id` which is created or passed in).

Example/available options:
```
{
  <instance_storage_config_resource_type> = {
    kinesis_firehose_config = optional({
      firehose_arn = string
    })
    kinesis_stream_config = optional({
      stream_arn = string
    })
    kinesis_video_stream_config = optional({
      encryption_config = {
        encryption_type = string
        key_id          = string
      }
      prefix                 = string
      retention_period_hours = number
    })
    s3_config = optional({
      bucket_name   = string
      bucket_prefix = string
      encryption_config = optional({
        encryption_type = string
        key_id          = string
      })
    })
    storage_type = string
  }
}
```
  EOF
}

################################################################################
# Hours of Operation
################################################################################
variable "hours_of_operations" {
  type        = any
  default     = {}
  description = <<-EOF
A map of Amazon Connect Hours of Operations.

The key of the map is the Hours of Operation `name`. The value is the configuration for that Hours of Operation, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_hours_of_operation) (except `name` which is the key, and `instance_id` which is created or passed in).

Example/available options:
```
{
  <hours_of_operation_name> = {
    config = [
      {
        day = string
        end_time = {
          hours   = number
          minutes = number
        }
        start_time = {
          hours   = number
          minutes = number
        }
      }
    ]
    description = optional(string)
    tags        = optional(map(string))
    time_zone   = string
  }
}
```
  EOF
}

variable "hours_of_operations_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to add to all Hours of Operations resources."
}

################################################################################
# Contact Flow / Module
################################################################################
variable "contact_flows" {
  type        = any
  default     = {}
  description = <<-EOF
A map of Amazon Connect Contact Flows.

The key of the map is the Contact Flow `name`. The value is the configuration for that Contact Flow, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_contact_flow) (except `name` which is the key, and `instance_id` which is created or passed in).

Example/available options:
```
{
  <contact_flow_name> = {
    content      = optional(string) # one required
    content_hash = optional(string) # one required
    description  = optional(string)
    filename     = optional(string) # one required
    tags         = optional(map(string))
    type         = optional(string)
  }
}
```
  EOF
}

variable "contact_flow_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to add to all Contact Flow resources."
}

variable "contact_flow_modules" {
  type        = any
  default     = {}
  description = <<-EOF
A map of Amazon Connect Contact Flow Modules.

The key of the map is the Contact Flow Module `name`. The value is the configuration for that Contact Flow, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_contact_flow_module) (except `name` which is the key, and `instance_id` which is created or passed in).

Example/available options:
```
{
  <contact_flow_module_name> = {
    content      = optional(string) # one required
    content_hash = optional(string) # one required
    description  = optional(string)
    filename     = optional(string) # one required
    tags         = optional(map(string))
  }
}
```
  EOF
}

variable "contact_flow_module_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to add to all Contact Flow Module resources."
}

################################################################################
# Queue
################################################################################
variable "queues" {
  type        = any
  default     = {}
  description = <<-EOF
A map of Amazon Connect Queues.

The key of the map is the Queue `name`. The value is the configuration for that Queue, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_queue) (except `name` which is the key, and `instance_id which` is created or passed in).

Example/available options:
```
{
  <queue_name> = {
    description            = optional(string)
    hours_of_operation_id  = string
    max_contacts           = optional(number)
    outbound_caller_config = optional({
      outbound_caller_id_name      = optional(string)
      outbound_caller_id_number_id = optional(string)
      outbound_flow_id             = optional(string)
    })
    quick_connect_ids = optional(list(string))
    status            = optional(string)
    tags              = optional(map(string))
  }
}
```
  EOF
}

variable "queue_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to add to all Queue resources."
}

################################################################################
# Quick Connect
################################################################################
variable "quick_connects" {
  type        = any
  default     = {}
  description = <<-EOF
A map of Amazon Connect Quick Connect.

The key of the map is the Quick Connect `name`. The value is the configuration for that Quick Connect, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_quick_connect) (except `name` which is the key, and `instance_id` which is created or passed in).

Example/available options:
```
{
  <quick_connect_name> = {
    description          = optional(string)
    quick_connect_config = {
      quick_connect_type = string
      phone_config = optional({
        phone_number = string
      })
      queue_config = optional({
        contact_flow_id = string
        queue_id        = string
      })
      user_config  = optional({
        contact_flow_id = string
        queue_id        = string
      })
    })
    tags = optional(map(string))
  }
}
```
  EOF
}

variable "quick_connect_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to add to all Quick Connect resources."
}

################################################################################
# Routing / Security Profiles
################################################################################
variable "routing_profiles" {
  type        = any
  default     = {}
  description = <<-EOF
A map of Amazon Connect Routing Profile.

The key of the map is the Routing Profile `name`. The value is the configuration for that Routing Profile, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_routing_profile) (except `name` which is the key, and `instance_id` which is created or passed in).

Example/available options:
```
{
  <routing_profile_name> = {
    default_outbound_queue_id = string
    description               = string
    media_concurrencies = [
      {
        channel     = string
        concurrency = number
      }
    ]
    queue_configs = optional([
      {
        channel  = string
        delay    = number
        priority = number
        queue_id = string
      }
    ])
    tags = optional(map(string))
  }
}
```
  EOF
}

variable "routing_profile_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to add to all Routing Profile resources."
}

variable "security_profiles" {
  type        = any
  default     = {}
  description = <<-EOF
A map of Amazon Connect Security Profile.

The key of the map is the Security Profile `name`. The value is the configuration for that Security Profile, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_security_profile) (except `name` which is the key, and `instance_id` which is created or passed in).

Example/available options:
```
{
  <security_profile_name> = {
    description = optional(string)
    permissions = optional(list(string))
    tags        = optional(map(string))
  }
}
```
  EOF
}

variable "security_profile_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to add to all Security Profile resources."
}

################################################################################
# Vocabulary
################################################################################
variable "vocabularies" {
  type        = any
  default     = {}
  description = <<-EOF
A map of Amazon Connect Vocabularies.

The key of the map is the Vocabulary `name`. The value is the configuration for that Vocabulary, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_vocabulary) (except `name` which is the key, and `instance_id` which is created or passed in).

Example/available options:
```
{
  <vocabulary_name> = {
    content       = string
    language_code = string
    tags          = optional(map(string))
  }
}
```
  EOF
}

variable "vocabulary_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to add to all Vocabulary resources."
}

################################################################################
# Lex Bot / Lambda Function Associations
################################################################################
variable "bot_associations" {
  type        = any
  default     = {}
  description = <<-EOF
A map of Amazon Connect Lex Bot Associations.

The key of the map is the Lex Bot `name`. The value is the configuration for that Lex Bot, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_bot_association) (except `name` which is the key, and `instance_id` which is created or passed in).

Example/available options:
```
{
  <lex_bot_association_name> = {
    name       = string
    lex_region = optional(string)
  }
}
```
  EOF
}

variable "lambda_function_associations" {
  type        = map(string)
  default     = {}
  description = <<-EOF
A map of Lambda Function ARNs to associate to the Amazon Connect Instance, the key is a static/arbitrary name and value is the Lambda ARN.

Example/available options:
```
{
  <lambda_function_association_name> = string
}
```
  EOF
}

################################################################################
# Users / Hierarchy Group / Structure
################################################################################
variable "users" {
  type        = any
  default     = {}
  description = <<-EOF
A map of Amazon Connect Users.

The key of the map is the User `name`. The value is the configuration for that User, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_user) (except `name` which is the key, and `instance_id` which is created or passed in).

Example/available options:
```
{
  <user_name> = {
    directory_user_id  = optional(string)
    hierarchy_group_id = optional(string)
    identity_info = optional({
      email      = optional(string)
      first_name = optional(string)
      last_name  = optional(string)
    })
    password = optional(string)
    phone_config = {
      phone_type                    = string
      after_contact_work_time_limit = optional(number)
      auto_accept                   = optional(bool)
      desk_phone_number             = optional(string)
    }
    routing_profile_id   = string
    security_profile_ids = list(string)
    tags                 = optional(map(string))
  }
}
```
  EOF
}

variable "user_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to add to all User resources."
}

variable "user_hierarchy_groups" {
  type        = any
  default     = {}
  description = <<-EOF
A map of Amazon Connect User Hierarchy Groups.

The key of the map is the User Hierarchy Group `name`. The value is the configuration for that User, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_user_hierarchy_group) (except `name` which is the key, and `instance_id` which is created or passed in).

Example/available options:
```
{
  <user_hierarchy_group_name> = {
    parent_group_id  = optional(string)
    tags             = optional(map(string))
  }
}
```
  EOF
}

variable "user_hierarchy_group_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to add to all User Hierarchy Group resources."
}

variable "user_hierarchy_structure" {
  type        = map(string)
  default     = {}
  description = <<-EOF
A map of Amazon Connect User Hierarchy Structure, containing keys for for zero or many levels: `level_one`, `level_two`, `level_three`, `level_four`, and `level_five`. The values are the `name` for that level. See [documentation here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_user_hierarchy_structure).

Example/available options:
```
{
  level_one = string
}
```
  EOF
}

################################################################################
# Tags
################################################################################
variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to add to all resources."
}
