output "url" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "api_id" {
  description = "API Gateway HTTP API ID"
  value       = aws_apigatewayv2_api.http_api.id
}

output "execution_arn" {
  description = "API Gateway Execution ARN"
  value       = aws_apigatewayv2_api.http_api.execution_arn
}