output "functions" {
  description = "Map of Lambda function names to their invoke ARNs"
  value = {
    "get_user_by_id"       = { invoke_arn = aws_lambda_function.get_user_by_id.invoke_arn },
    "get_user_by_email"    = { invoke_arn = aws_lambda_function.get_user_by_email.invoke_arn },
    "get_hosts_by_user_id" = { invoke_arn = aws_lambda_function.get_hosts_by_user_id.invoke_arn },
    "get_host_by_id"       = { invoke_arn = aws_lambda_function.get_host_by_id.invoke_arn }
  }
}
