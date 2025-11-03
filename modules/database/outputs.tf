output "db_instance_id" {
  value = "${var.project_name}-postgres"
}

output "db_instance_address" {
  value = module.aws_rds.db_instance_address
}

output "db_instance_port" {
  value = module.aws_rds.db_instance_port
}

output "db_instance_endpoint" {
  value = "${module.aws_rds.db_instance_address}:${module.aws_rds.db_instance_port}"
}

output "db_instance_resource_id" {
  value = module.aws_rds.db_instance_resource_id
}
