provider "aws" {
  region = var.aws_region
}

# Secret for Webull & AWS credentials
resource "aws_secretsmanager_secret" "webull" {
  name        = "webull_credentials"
  description = "Webull and AWS access keys"
}

resource "aws_secretsmanager_secret_version" "webull" {
  secret_id = aws_secretsmanager_secret.webull.id
  secret_string = jsonencode({
    WEBULL_USERNAME       = var.webull_username,
    WEBULL_PASSWORD       = var.webull_password,
    AWS_ACCESS_KEY_ID     = var.aws_access_key_id,
    AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key,
  })
}

resource "aws_iam_role" "lambda_exec" {
  count              = var.existing_lambda_role_name == "" ? 1 : 0
  name               = "ema_trading_lambda_exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_role" "existing" {
  count = var.existing_lambda_role_name != "" ? 1 : 0
  name  = var.existing_lambda_role_name
}

locals {
  lambda_role_arn      = var.existing_lambda_role_name == "" ? aws_iam_role.lambda_exec[0].arn : data.aws_iam_role.existing[0].arn
  lambda_function_arn  = var.existing_lambda_function_name == "" ? aws_lambda_function.ema_trading[0].arn : data.aws_lambda_function.existing[0].arn
  lambda_function_name = var.existing_lambda_function_name == "" ? aws_lambda_function.ema_trading[0].function_name : data.aws_lambda_function.existing[0].function_name
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_policy_doc" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.webull.arn
    ]
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  count  = var.existing_lambda_role_name == "" ? 1 : 0
  name   = "ema_trading_policy"
  role   = aws_iam_role.lambda_exec[0].id
  policy = data.aws_iam_policy_document.lambda_policy_doc.json
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src"
  output_path = "${path.module}/lambda_package.zip"
}

data "aws_lambda_function" "existing" {
  count         = var.existing_lambda_function_name != "" ? 1 : 0
  function_name = var.existing_lambda_function_name
}

resource "aws_lambda_function" "ema_trading" {
  count            = var.existing_lambda_function_name == "" ? 1 : 0
  function_name    = "ema_trading_function"
  handler          = "src.lambda_function.handler"
  runtime          = "python3.9"
  role             = local.lambda_role_arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 60
  environment {
    variables = {
      SECRET_ARN = aws_secretsmanager_secret.webull.arn
    }
  }
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "ema_trading_schedule"
  schedule_expression = "cron(0/10 13-20 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "ema_trading_lambda"
  arn       = local.lambda_function_arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}
