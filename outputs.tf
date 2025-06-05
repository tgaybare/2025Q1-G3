
output "react_app_bucket_website_url" {
  value       = module.react_app_bucket.website_url
  description = "URL to access the React app"
}

output "SlaveServer1_ip" {
  value = module.ec2_slaves["slave_1"].public_ip
}

output "SlaveServer2_ip" {
  value = module.ec2_slaves["slave_2"].public_ip
}