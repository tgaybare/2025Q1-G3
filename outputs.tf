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

output "SlaveServer1_ip" {
  value = module.ec2_slaves["slave_1"].public_ip
}

output "SlaveServer2_ip" {
  value = module.ec2_slaves["slave_2"].public_ip
}