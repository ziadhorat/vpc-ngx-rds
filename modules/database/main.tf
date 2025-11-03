resource "aws_ssm_parameter" "db_info" {
  name  = "/${var.project_name}/db/info"
  type  = "String"
  value = jsonencode({
    host         = module.aws_rds.db_instance_address
    port         = module.aws_rds.db_instance_port
    dbname       = var.db_name
    username     = var.db_username
    resource_id  = module.aws_rds.db_instance_resource_id
  })
  tags  = var.common_tags
}

resource "aws_db_parameter_group" "db_params" {
  name   = "${var.project_name}-postgres-params"
  family = "postgres${var.db_major_version}"
  
  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }
  
  tags = var.common_tags
}

module "aws_rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "${var.project_name}-postgres"

  engine               = "postgres"
  engine_version       = var.db_engine_version
  family              = "postgres${var.db_major_version}"
  major_engine_version = var.db_major_version

  instance_class      = var.db_instance_class
  allocated_storage   = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_encrypted   = true
  storage_type        = "gp3"

  db_name  = var.db_name
  username = var.db_username
  port     = 5432
  manage_master_user_password = true

  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.db.name
  create_db_parameter_group = false
  parameter_group_name   = aws_db_parameter_group.db_params.name

  deletion_protection = var.enable_deletion_protection
  skip_final_snapshot = !var.enable_deletion_protection

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-postgres"
  })
}

resource "aws_db_subnet_group" "db" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags       = var.common_tags
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "PostgreSQL RDS security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Postgres from nginx"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.nginx_security_group_id]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-db-sg"
  })
}
