variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "webull_username" {
  description = "Webull username"
  type        = string
}

variable "webull_password" {
  description = "Webull password"
  type        = string
}

variable "aws_access_key_id" {
  description = "AWS access key ID for API calls"
  type        = string
}

variable "aws_secret_access_key" {
  description = "AWS secret access key for API calls"
  type        = string
}
