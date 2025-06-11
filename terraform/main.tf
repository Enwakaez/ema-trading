provider "aws" {
  region = var.aws_region
}


# Existing secret containing Webull and AWS credentials
data "aws_secretsmanager_secret" "webull" {
  arn = var.secret_arn
}

resource "aws_iam_role" "lambda_exec" {
  name               = "ema_trading_lambda_exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
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
      var.secret_arn
    ]
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "ema_trading_policy"
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.lambda_policy_doc.json
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src"
  output_path = "${path.module}/lambda_package.zip"
}

resource "aws_lambda_function" "ema_trading" {
  function_name    = "ema_trading_function"
  handler          = "src.lambda_function.handler"
  runtime          = "python3.9"
  role             = aws_iam_role.lambda_exec.arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 60
  environment {
    variables = {
      SECRET_ARN = var.secret_arn
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
  arn       = aws_lambda_function.ema_trading.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ema_trading.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}
