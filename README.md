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
   - `AWS_KEY_ID`
   - `AWS_SECRET`
3. **Push** to `main`—GitHub Actions will:
   - Initialize and apply Terraform (using existing Secrets Manager secret).
   - Deploy the Lambda function.

### Provisioning Secrets

Terraform expects a pre-existing Secrets Manager secret with those values. Pass its ARN during apply:
```bash
terraform init
terraform apply -var="secret_arn=${SECRET_ARN}"
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
