variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "nginx_security_group_id" {
  type = string
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_username" {
  type    = string
  default = "postgres"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_max_allocated_storage" {
  type    = number
  default = 100
}

variable "db_engine_version" {
  type    = string
  default = "15.14"
}

variable "db_major_version" {
  type    = string
  default = "15"
}

variable "enable_deletion_protection" {
  type    = bool
  default = false
}

variable "aws_region" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
