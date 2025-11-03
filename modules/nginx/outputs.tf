output "instance_id" {
  value = aws_instance.nginx.id
}

output "instance_public_ip" {
  value = aws_instance.nginx.public_ip
}

output "instance_private_ip" {
  value = aws_instance.nginx.private_ip
}

output "security_group_id" {
  value = aws_security_group.nginx.id
}

output "url" {
  value = "http://${aws_instance.nginx.public_ip}"
}

output "iam_role_name" {
  value = aws_iam_role.nginx.name
}
