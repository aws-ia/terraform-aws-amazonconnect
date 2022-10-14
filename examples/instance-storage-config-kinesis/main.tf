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

  instance_identity_management_type = "CONNECT_MANAGED"
  instance_inbound_calls_enabled    = true
  instance_outbound_calls_enabled   = true
  instance_alias                    = random_string.instance_alias.result

  # Instance Storage Configuration
  instance_storage_configs = {
    MEDIA_STREAMS = {
      storage_type = "KINESIS_VIDEO_STREAM"

      kinesis_video_stream_config = {
        prefix                 = "encrypted-media"
        retention_period_hours = 24

        encryption_config = {
          encryption_type = "KMS"
          key_id          = aws_kms_key.example.arn
        }
      }
    }
  }
}

# KMS Key
resource "aws_kms_key" "example" {
  policy              = data.aws_iam_policy_document.example_key_policy.json
  enable_key_rotation = true
}

data "aws_iam_policy_document" "example_key_policy" {
  # Key Administrators
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  # Key Users
  statement {
    principals {
      type        = "AWS"
      identifiers = [module.amazon_connect.instance.service_role]
    }

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*"
    ]
    resources = ["*"]
  }
}
