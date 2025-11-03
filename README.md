# VPC, Nginx, and PostgreSQL Terraform Project

Terraform setup for VPC with nginx web server and PostgreSQL RDS - with a health check script that displays to the home page (and cli).

## Quick Start

```bash
# use sso or cli credentials:
export AWS_ACCESS_KEY_ID="***"
export AWS_SECRET_ACCESS_KEY="***"
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars
terraform init
terraform plan
terraform apply
```

## Configuration

Key variables in `terraform.tfvars`:
- `aws_region`: AWS region
- `db_username`: Database username
- `db_name`: Initial database name

## Todo

- ALB infront of EC2
- Cert on ALB for SSL
