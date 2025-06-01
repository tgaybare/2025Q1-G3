output "api_endpoint" {
  description = "Base URL of the API Gateway"
  value = module.api_gateway.api_endpoint
}

output "api_gateway_arn" {
  description = "ARN of the API Gateway"
  value       = module.api_gateway.api_gateway_arn
}

output "react_app_bucket_name" {
  value = module.react_app_bucket.bucket_name
}

output "react_app_bucket_website_url" {
  value       = module.react_app_bucket.website_url
  description = "URL to access the React app"
}

