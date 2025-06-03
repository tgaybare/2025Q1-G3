output "api_endpoint" {
  description = "Base URL of the API Gateway"
  value = module.api_gateway.api_endpoint
}

output "api_gateway_arn" {
  description = "ARN of the API Gateway"
  value       = module.api_gateway.api_gateway_arn
}

output "api_endpoint_zabbix" {
  description = "Base URL of the API Gateway"
  value = module.apigw.get_metrics.url
}

output "api_gateway_arn_zabbix" {
  description = "ARN of the API Gateway"
  value       = module.apigw.get_metrics.execution_arn
}

output "react_app_bucket_name" {
  value = module.react_app_bucket.bucket_name
}

output "react_app_bucket_website_url" {
  value       = module.react_app_bucket.website_url
  description = "URL to access the React app"
}

output "cognito_user_pool_id" {
  value = module.cognito.user_pool_id
}

output "cognito_client_id" {
  value = module.cognito.client_id
}
