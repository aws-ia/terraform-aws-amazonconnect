# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
  instance_id = var.create_instance ? aws_connect_instance.this[0].id : var.instance_id
}

################################################################################
# Instance
################################################################################
resource "aws_connect_instance" "this" {
  count = var.create_instance ? 1 : 0

  # required
  identity_management_type = var.instance_identity_management_type
  inbound_calls_enabled    = var.instance_inbound_calls_enabled
  outbound_calls_enabled   = var.instance_outbound_calls_enabled

  # optional
  auto_resolve_best_voices_enabled = var.instance_auto_resolve_best_voices_enabled
  contact_flow_logs_enabled        = var.instance_contact_flow_logs_enabled
  contact_lens_enabled             = var.instance_contact_lens_enabled
  directory_id                     = var.instance_directory_id
  early_media_enabled              = var.instance_early_media_enabled
  instance_alias                   = var.instance_alias

  lifecycle {
    precondition {
      condition     = var.create_instance ? var.instance_identity_management_type != null : true
      error_message = "When create_instance is true, instance_identity_management_type is required."
    }

    precondition {
      condition     = var.create_instance ? var.instance_inbound_calls_enabled != null : true
      error_message = "When create_instance is true, instance_inbound_calls_enabled is required."
    }

    precondition {
      condition     = var.create_instance ? var.instance_outbound_calls_enabled != null : true
      error_message = "When create_instance is true, instance_outbound_calls_enabled is required."
    }
  }
}

################################################################################
# Instance Storage Config
################################################################################
resource "aws_connect_instance_storage_config" "this" {
  for_each = var.instance_storage_configs

  # required
  instance_id   = local.instance_id
  resource_type = each.key

  storage_config {
    storage_type = each.value.storage_type

    # optional
    dynamic "kinesis_firehose_config" {
      for_each = contains(keys(each.value), "kinesis_firehose_config") ? [1] : []

      content {
        firehose_arn = each.value.kinesis_firehose_config.firehose_arn
      }
    }

    dynamic "kinesis_stream_config" {
      for_each = contains(keys(each.value), "kinesis_stream_config") ? [1] : []

      content {
        stream_arn = each.value.kinesis_stream_config.stream_arn
      }
    }

    dynamic "kinesis_video_stream_config" {
      for_each = contains(keys(each.value), "kinesis_video_stream_config") ? [1] : []

      content {
        encryption_config {
          encryption_type = each.value.kinesis_video_stream_config.encryption_config.encryption_type
          key_id          = each.value.kinesis_video_stream_config.encryption_config.key_id
        }

        prefix                 = each.value.kinesis_video_stream_config.prefix
        retention_period_hours = each.value.kinesis_video_stream_config.retention_period_hours
      }
    }

    dynamic "s3_config" {
      for_each = contains(keys(each.value), "s3_config") ? [1] : []

      content {
        bucket_name   = each.value.s3_config.bucket_name
        bucket_prefix = each.value.s3_config.bucket_prefix

        dynamic "encryption_config" {
          for_each = contains(keys(each.value.s3_config), "encryption_config") ? [1] : []

          content {
            encryption_type = each.value.s3_config.encryption_config.encryption_type
            key_id          = each.value.s3_config.encryption_config.key_id
          }
        }
      }
    }
  }
}

################################################################################
# Hours of Operation
################################################################################
resource "aws_connect_hours_of_operation" "this" {
  for_each = var.hours_of_operations

  # required
  dynamic "config" {
    for_each = each.value.config

    content {
      day = config.value.day

      end_time {
        hours   = config.value.end_time.hours
        minutes = config.value.end_time.minutes
      }

      start_time {
        hours   = config.value.start_time.hours
        minutes = config.value.start_time.minutes
      }
    }
  }

  instance_id = local.instance_id
  name        = each.key
  time_zone   = each.value.time_zone

  # optional
  description = try(each.value.description, null)

  # tags
  tags = merge(
    { Name = each.key },
    var.tags,
    var.hours_of_operations_tags,
    try(each.value.tags, {})
  )
}

################################################################################
# Contact Flow / Module
################################################################################
resource "aws_connect_contact_flow" "this" {
  for_each = var.contact_flows

  # required
  instance_id = local.instance_id
  name        = each.key

  # content (one required)
  content      = try(each.value.content, null)
  content_hash = try(each.value.content_hash, null)
  filename     = try(each.value.filename, null)

  # optional
  description = try(each.value.description, null)
  type        = try(each.value.type, null)

  # tags
  tags = merge(
    { Name = each.key },
    var.tags,
    var.contact_flow_tags,
    try(each.value.tags, {})
  )
}

resource "aws_connect_contact_flow_module" "this" {
  for_each = var.contact_flow_modules

  # required
  instance_id = local.instance_id
  name        = each.key

  # content (one required)
  content      = try(each.value.content, null)
  content_hash = try(each.value.content_hash, null)
  filename     = try(each.value.filename, null)

  # optional
  description = try(each.value.description, null)

  # tags
  tags = merge(
    { Name = each.key },
    var.tags,
    var.contact_flow_module_tags,
    try(each.value.tags, {})
  )
}

################################################################################
# Queue
################################################################################
resource "aws_connect_queue" "this" {
  for_each = var.queues

  # required
  hours_of_operation_id = each.value.hours_of_operation_id
  instance_id           = local.instance_id
  name                  = each.key

  # optional
  description  = try(each.value.description, null)
  max_contacts = try(each.value.max_contacts, null)

  dynamic "outbound_caller_config" {
    for_each = contains(keys(each.value), "outbound_caller_config") ? [1] : []

    content {
      outbound_caller_id_name      = try(each.value.outbound_caller_config.outbound_caller_id_name, null)
      outbound_caller_id_number_id = try(each.value.outbound_caller_config.outbound_caller_id_number_id, null)
      outbound_flow_id             = try(each.value.outbound_caller_config.outbound_flow_id, null)
    }
  }

  quick_connect_ids = try(each.value.quick_connect_ids, null)
  status            = try(each.value.status, null)

  # tags
  tags = merge(
    { Name = each.key },
    var.tags,
    var.queue_tags,
    try(each.value.tags, {})
  )
}

################################################################################
# Quick Connect
################################################################################
resource "aws_connect_quick_connect" "this" {
  for_each = var.quick_connects

  # required
  instance_id = local.instance_id
  name        = each.key

  quick_connect_config {
    quick_connect_type = each.value.quick_connect_config.quick_connect_type

    # optional
    dynamic "phone_config" {
      for_each = contains(keys(each.value.quick_connect_config), "phone_config") ? [1] : []

      content {
        phone_number = each.value.quick_connect_config.phone_config.phone_number
      }
    }

    dynamic "queue_config" {
      for_each = contains(keys(each.value.quick_connect_config), "queue_config") ? [1] : []

      content {
        contact_flow_id = each.value.quick_connect_config.queue_config.contact_flow_id
        queue_id        = each.value.quick_connect_config.queue_config.queue_id
      }
    }

    dynamic "user_config" {
      for_each = contains(keys(each.value.quick_connect_config), "user_config") ? [1] : []

      content {
        contact_flow_id = each.value.quick_connect_config.user_config.contact_flow_id
        user_id         = each.value.quick_connect_config.user_config.user_id
      }
    }
  }

  # optional
  description = try(each.value.description, null)

  # tags
  tags = merge(
    { Name = each.key },
    var.tags,
    var.quick_connect_tags,
    try(each.value.tags, {})
  )
}

################################################################################
# Routing / Security Profiles
################################################################################
resource "aws_connect_routing_profile" "this" {
  for_each = var.routing_profiles

  # required
  default_outbound_queue_id = each.value.default_outbound_queue_id
  description               = each.value.description
  instance_id               = local.instance_id

  dynamic "media_concurrencies" {
    for_each = each.value.media_concurrencies

    content {
      channel     = media_concurrencies.value.channel
      concurrency = media_concurrencies.value.concurrency
    }
  }

  name = each.key

  # optional
  dynamic "queue_configs" {
    for_each = contains(keys(each.value), "queue_configs") ? each.value.queue_configs : []

    content {
      channel  = queue_configs.value.channel
      delay    = queue_configs.value.delay
      priority = queue_configs.value.priority
      queue_id = queue_configs.value.queue_id
    }
  }

  # tags
  tags = merge(
    { Name = each.key },
    var.tags,
    var.routing_profile_tags,
    try(each.value.tags, {})
  )
}

resource "aws_connect_security_profile" "this" {
  for_each = var.security_profiles

  # required
  instance_id = local.instance_id
  name        = each.key

  # optional
  description = try(each.value.description, null)
  permissions = try(each.value.permissions, null)

  # tags
  tags = merge(
    { Name = each.key },
    var.tags,
    var.security_profile_tags,
    try(each.value.tags, {})
  )
}

################################################################################
# Vocabulary
################################################################################
resource "aws_connect_vocabulary" "this" {
  for_each = var.vocabularies

  # required
  content       = each.value.content
  instance_id   = local.instance_id
  language_code = each.value.language_code
  name          = each.key

  # tags
  tags = merge(
    { Name = each.key },
    var.tags,
    var.vocabulary_tags,
    try(each.value.tags, {})
  )
}

################################################################################
# Lex Bot / Lambda Function Associations
################################################################################
resource "aws_connect_bot_association" "this" {
  for_each = var.bot_associations

  # required
  instance_id = local.instance_id

  lex_bot {
    name = each.value.name

    # optional
    lex_region = try(each.value.lex_region, null)
  }
}

resource "aws_connect_lambda_function_association" "this" {
  for_each = var.lambda_function_associations

  function_arn = each.value
  instance_id  = local.instance_id
}

################################################################################
# Users / Hierarchy Group / Structure
################################################################################
resource "aws_connect_user" "this" {
  for_each = var.users

  # required
  instance_id = local.instance_id
  name        = each.key

  phone_config {
    phone_type = each.value.phone_config.phone_type

    # optional
    after_contact_work_time_limit = try(each.value.phone_config.after_contact_work_time_limit, null)
    auto_accept                   = try(each.value.phone_config.auto_accept, null)
    desk_phone_number             = try(each.value.phone_config.desk_phone_number, null)
  }

  routing_profile_id   = each.value.routing_profile_id
  security_profile_ids = each.value.security_profile_ids

  # optional
  directory_user_id  = try(each.value.directory_user_id, null)
  hierarchy_group_id = try(each.value.hierarchy_group_id, null)

  dynamic "identity_info" {
    for_each = contains(keys(each.value), "identity_info") ? [1] : []

    content {
      email      = try(each.value.identity_info.email, null)
      first_name = try(each.value.identity_info.first_name, null)
      last_name  = try(each.value.identity_info.last_name, null)
    }
  }

  password = try(each.value.password, null)

  # tags
  tags = merge(
    { Name = each.key },
    var.tags,
    var.user_tags,
    try(each.value.tags, {})
  )
}

resource "aws_connect_user_hierarchy_group" "this" {
  for_each = var.user_hierarchy_groups

  # required
  instance_id = local.instance_id
  name        = each.key

  # optional
  parent_group_id = try(each.value.parent_group_id, null)

  # tags
  tags = merge(
    { Name = each.key },
    var.tags,
    var.user_hierarchy_group_tags,
    try(each.value.tags, {})
  )
}

resource "aws_connect_user_hierarchy_structure" "this" {
  count = length(keys(var.user_hierarchy_structure)) > 0 ? 1 : 0

  # required
  instance_id = local.instance_id

  hierarchy_structure {
    dynamic "level_one" {
      for_each = contains(keys(var.user_hierarchy_structure), "level_one") ? [1] : []

      content {
        name = var.user_hierarchy_structure.level_one
      }
    }

    # optional
    dynamic "level_two" {
      for_each = contains(keys(var.user_hierarchy_structure), "level_two") ? [1] : []

      content {
        name = var.user_hierarchy_structure.level_two
      }
    }

    dynamic "level_three" {
      for_each = contains(keys(var.user_hierarchy_structure), "level_three") ? [1] : []

      content {
        name = var.user_hierarchy_structure.level_three
      }
    }

    dynamic "level_four" {
      for_each = contains(keys(var.user_hierarchy_structure), "level_four") ? [1] : []

      content {
        name = var.user_hierarchy_structure.level_four
      }
    }

    dynamic "level_five" {
      for_each = contains(keys(var.user_hierarchy_structure), "level_five") ? [1] : []

      content {
        name = var.user_hierarchy_structure.level_five
      }
    }
  }
}
