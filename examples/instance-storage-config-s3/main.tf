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
    CALL_RECORDINGS = {
      storage_type = "S3"

      s3_config = {
        bucket_name   = aws_s3_bucket.example.id
        bucket_prefix = "CALL_RECORDINGS"

        encryption_config = {
          encryption_type = "KMS"
          key_id          = aws_kms_key.example.arn
        }
      }
    }
  }
}

# S3
resource "aws_s3_bucket" "example" {
  force_destroy = true
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.example.id
  acl    = "private"
}

resource "aws_s3_bucket_logging" "example" {
  bucket        = aws_s3_bucket.example.id
  target_bucket = aws_s3_bucket.logging.id
  target_prefix = "${aws_s3_bucket.example.id}/logs/"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket                  = aws_s3_bucket.example.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.example.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Logging
resource "aws_s3_bucket" "logging" {
  force_destroy = true
}

resource "aws_s3_bucket_acl" "logging" {
  bucket = aws_s3_bucket.logging.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_public_access_block" "logging" {
  bucket                  = aws_s3_bucket.logging.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging" {
  bucket = aws_s3_bucket.logging.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "logging" {
  bucket = aws_s3_bucket.logging.id

  versioning_configuration {
    status = "Enabled"
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
