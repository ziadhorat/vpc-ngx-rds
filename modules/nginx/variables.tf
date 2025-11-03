variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
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
