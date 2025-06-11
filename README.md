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
   - *(optional)* `EXISTING_LAMBDA_ROLE` – name of an IAM role to reuse
   - *(optional)* `EXISTING_LAMBDA_FUNCTION` – existing Lambda function name
3. **Push** to `main`—GitHub Actions will:
   - Initialize and apply Terraform (creating Secrets Manager secret).
   - Deploy the Lambda function.

### Reusing Existing Lambda Resources

Set `existing_lambda_role_name` or `existing_lambda_function_name` when you
already have these resources provisioned. Provide their values via the optional
GitHub Secrets listed above. The workflow will import the resources into the
Terraform state before applying changes, allowing the rest of the infrastructure
to reference them.

Example manual apply:
```bash
terraform apply -var="existing_lambda_role_name=my-role" \
  -var="existing_lambda_function_name=my-func" [...]
```

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
