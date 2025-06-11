output "lambda_function_name" {
  value = local.lambda_function_name
}

output "secret_arn" {
  value = aws_secretsmanager_secret.webull.arn
}
