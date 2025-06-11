# EMA Trading Bot Prototype

## Overview
Automated trading application using Python, AWS Lambda, Webull API, and AWS Secrets Manager. Trades NVIDIA (NVDA) and Palantir (PLTR) based on EMA crossover and RSI signals.

## Project Structure
```
.github/
└── workflows/ci-cd.yml
terraform/
├── main.tf
├── variables.tf
└── outputs.tf
src/
├── lambda_function.py
├── trading/
│   ├── indicators.py
│   ├── strategy.py
│   └── risk_management.py
└── utils/
    └── webull_client.py
.gitignore
.env.example
requirements.txt
README.md
```

## Deployment

1. **Clone** the repository.
2. **Set** GitHub Secrets:
   - `SECRET_ARN` - ARN of the AWS Secrets Manager secret containing Webull and AWS credentials
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
3. **Push** to `main`—GitHub Actions will:
   - Import existing Lambda, IAM role, and CloudWatch schedule by name
     before applying Terraform.
   - Initialize and apply Terraform (using the provided Secrets Manager ARN).
   - Deploy the Lambda function.

### Provisioning Secrets

Terraform expects a pre-existing Secrets Manager secret with those values. Pass its ARN during apply:
```bash
terraform init
terraform apply -var="secret_arn=${SECRET_ARN}"
```

### Importing Existing Resources

If the Lambda function, IAM role, or CloudWatch schedule already exist,
Terraform can import them by name. The CI workflow performs these imports
automatically, but you may also run them locally:

```bash
terraform import aws_lambda_function.ema_trading ema_trading_function
terraform import aws_iam_role.lambda_exec ema_trading_lambda_exec
terraform import aws_cloudwatch_event_rule.schedule ema_trading_schedule
```

## Usage

- Lambda runs every 10 minutes during US market hours (9:30–16:30 ET).
- Monitor logs in **CloudWatch Logs** `/aws/lambda/ema_trading_function`.
- Use Log Insights query:
```sql
fields @timestamp, @message
| filter @message like /Placing/
| sort @timestamp desc
| limit 20
```
