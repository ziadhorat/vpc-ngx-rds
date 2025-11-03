provider "aws" {
  region = var.aws_region
  default_tags {
    tags = local.common_tags
  }
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "vpc" {
  source = "./modules/vpc"
  project_name  = var.project_name
  vpc_cidr      = var.vpc_cidr
  environment   = var.environment
  common_tags   = local.common_tags
}

module "nginx" {
  source = "./modules/nginx"
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  instance_type     = var.nginx_instance_type
  aws_region        = data.aws_region.current.name
  aws_account_id    = data.aws_caller_identity.current.account_id
  common_tags       = local.common_tags
  depends_on        = [module.vpc]
}

module "database" {
  source = "./modules/database"
  project_name            = var.project_name
  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  nginx_security_group_id = module.nginx.security_group_id
  db_name                 = var.db_name
  db_username             = var.db_username
  db_instance_class       = var.db_instance_class
  db_allocated_storage    = var.db_allocated_storage
  db_max_allocated_storage = var.db_max_allocated_storage
  db_engine_version       = var.db_engine_version
  db_major_version        = var.db_major_version
  enable_deletion_protection = var.enable_deletion_protection
  aws_region              = data.aws_region.current.name
  aws_account_id          = data.aws_caller_identity.current.account_id
  common_tags             = local.common_tags
  depends_on              = [module.nginx]
}
