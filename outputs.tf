output "react_app_bucket_name" {
  value = module.react_app_bucket.bucket_name
}

output "react_app_bucket_website_url" {
  value       = module.react_app_bucket.website_url
  description = "URL to access the React app"
}
