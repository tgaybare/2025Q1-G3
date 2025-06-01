output "users_table_arn" {
  description = "ARN of the Users DynamoDB table"
  value       = aws_dynamodb_table.users_table.arn
}

output "users_table_name" {
  description = "Name of the Users DynamoDB table"
  value       = aws_dynamodb_table.users_table.name
}

output "hosts_table_arn" {
  description = "ARN of the Hosts DynamoDB table"
  value       = aws_dynamodb_table.hosts_table.arn
}

output "hosts_table_name" {
  description = "Name of the Hosts DynamoDB table"
  value       = aws_dynamodb_table.hosts_table.name
}
