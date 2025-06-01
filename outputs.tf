output "api_endpoint" {
  description = "Base URL of the API Gateway"
  value = module.api_gateway.api_endpoint
}

output "api_gateway_arn" {
  description = "ARN of the API Gateway"
  value       = module.api_gateway.api_gateway_arn
}