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
   - `WEBULL_USERNAME`
   - `WEBULL_PASSWORD`
   - `AWS_KEY_ID`
   - `AWS_SECRET`
3. **Push** to `main`—GitHub Actions will:
   - Initialize and apply Terraform (creating Secrets Manager secret).
   - Deploy the Lambda function.

### Provisioning Secrets

The Terraform setup will create an AWS Secrets Manager secret named `webull_credentials` containing:
- `WEBULL_USERNAME`
- `WEBULL_PASSWORD`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

Provide these via Terraform vars (GitHub Actions):
```bash
terraform init
terraform apply   -var="webull_username=${{ secrets.WEBULL_USERNAME }}"   -var="webull_password=${{ secrets.WEBULL_PASSWORD }}"   -var="aws_access_key_id=${{ secrets.AWS_KEY_ID }}"   -var="aws_secret_access_key=${{ secrets.AWS_SECRET }}"
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
