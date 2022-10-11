locals {
  instance_storage_configs = {
    # S3
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
    CHAT_TRANSCRIPTS = {
      storage_type = "S3"

      s3_config = {
        bucket_name   = aws_s3_bucket.example.id
        bucket_prefix = "CHAT_TRANSCRIPTS"

        encryption_config = {
          encryption_type = "KMS"
          key_id          = aws_kms_key.example.arn
        }
      }
    }
    SCHEDULED_REPORTS = {
      storage_type = "S3"

      s3_config = {
        bucket_name   = aws_s3_bucket.example.id
        bucket_prefix = "SCHEDULED_REPORTS"

        encryption_config = {
          encryption_type = "KMS"
          key_id          = aws_kms_key.example.arn
        }
      }
    }

    # Kinesis
    AGENT_EVENTS = {
      storage_type = "KINESIS_STREAM"

      kinesis_stream_config = {
        stream_arn = aws_kinesis_stream.example.arn
      }
    }
    CONTACT_TRACE_RECORDS = {
      storage_type = "KINESIS_FIREHOSE"

      kinesis_firehose_config = {
        firehose_arn = aws_kinesis_firehose_delivery_stream.example.arn
      }
    }
    MEDIA_STREAMS = {
      storage_type = "KINESIS_VIDEO_STREAM"

      kinesis_video_stream_config = {
        prefix                 = "MEDIA_STREAMS"
        retention_period_hours = 24

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

# Kinesis
resource "aws_kinesis_stream" "example" {
  name            = module.amazon_connect.instance.id
  encryption_type = "KMS"
  kms_key_id      = aws_kms_key.example.id

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "example" {
  name        = module.amazon_connect.instance.id
  destination = "extended_s3"

  server_side_encryption {
    enabled  = true
    key_type = "CUSTOMER_MANAGED_CMK"
    key_arn  = aws_kms_key.example.arn
  }

  extended_s3_configuration {
    bucket_arn = aws_s3_bucket.example.arn
    prefix     = "CONTACT_TRACE_RECORDS/"
    role_arn   = aws_iam_role.firehose.arn
  }
}

# IAM
resource "aws_iam_role" "firehose" {
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role_policy.json
}

data "aws_iam_policy_document" "firehose_assume_role_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "firehose" {
  role   = aws_iam_role.firehose.id
  policy = data.aws_iam_policy_document.firehose_role_policy.json
}

data "aws_iam_policy_document" "firehose_role_policy" {
  statement {
    actions = [
      "s3:GetBucket",
      "s3:GetBucketAcl",
      "s3:ListBucket",
      "s3:ListBucketAcl"
    ]
    resources = [aws_s3_bucket.example.arn]
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersionAcl"
    ]
    resources = ["${aws_s3_bucket.example.arn}/CONTACT_TRACE_RECORDS/*"]
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
      type = "AWS"

      identifiers = [
        module.amazon_connect.instance.service_role,
        aws_iam_role.firehose.arn
      ]
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
