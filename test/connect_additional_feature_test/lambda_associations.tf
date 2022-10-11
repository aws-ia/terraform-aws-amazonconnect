locals {
  lambda_function_associations = {
    example = aws_lambda_function.example.arn
  }
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
