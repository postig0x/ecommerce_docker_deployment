output "instance" {
  value = aws_db_instance.postgres_db
}

output "endpoint" {
  value = aws_db_instance.postgres_db.endpoint
}