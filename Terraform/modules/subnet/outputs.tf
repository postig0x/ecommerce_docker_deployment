output "public_id" {
  value = aws_subnet.public[*].id
}

output "private_id" {
  value = aws_subnet.private[*].id
}