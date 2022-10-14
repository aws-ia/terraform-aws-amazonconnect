locals {
  bot_associations = {
    example = {
      name = aws_lex_bot.example.name
    }
  }

  lambda_function_associations = {
    example = aws_lambda_function.example.arn
  }
}

# Lex Bot
resource "aws_lex_bot" "example" {
  name             = "example"
  child_directed   = false
  process_behavior = "BUILD"

  intent {
    intent_name    = aws_lex_intent.example.name
    intent_version = aws_lex_intent.example.version
  }

  abort_statement {
    message {
      content      = "Sorry, I am not able to assist at this time."
      content_type = "PlainText"
    }
  }

  clarification_prompt {
    max_attempts = 2

    message {
      content      = "I didn't understand you, what would you like to do?"
      content_type = "PlainText"
    }
  }
}

resource "aws_lex_intent" "example" {
  name = "example"

  fulfillment_activity {
    type = "ReturnIntent"
  }

  sample_utterances = [
    "example one",
    "example two"
  ]
}

# Lambda Function
resource "aws_lambda_function" "example" {
  function_name = "example"
  role          = aws_iam_role.lambda_function.arn
  filename      = data.archive_file.lambda_function.output_path
  handler       = "index.handler"
  runtime       = "nodejs16.x"

  environment {
    variables = {
      CONNECT_INSTANCE_ID = try(module.amazon_connect.instance.id, null)
    }
  }

  tracing_config {
    mode = "Active"
  }
}

data "archive_file" "lambda_function" {
  type             = "zip"
  source_file      = "${path.module}/lambda-function/index.js"
  output_path      = "${path.module}/lambda-function/function.zip"
  output_file_mode = "0666"
}

resource "aws_iam_role" "lambda_function" {
  assume_role_policy = data.aws_iam_policy_document.lambda_function_assume_role_policy.json
}

data "aws_iam_policy_document" "lambda_function_assume_role_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
