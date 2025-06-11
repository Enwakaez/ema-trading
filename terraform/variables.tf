variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}


variable "secret_arn" {
  description = "ARN of existing Secrets Manager secret with credentials"
  type        = string
}
