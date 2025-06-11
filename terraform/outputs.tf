output "lambda_function_name" {
  value = aws_lambda_function.ema_trading.function_name
}

output "secret_arn" {
  value = var.secret_arn
}
