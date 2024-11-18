output "app_instance_id" {
  value = aws_instance.app[*].id
}

output "app_sg_id" {
  value = aws_security_group.app.id
}