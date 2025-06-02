variable "user_pool_name" {}
variable "app_client_name" {}
variable "callback_urls" {
  type = list(string)
}
variable "logout_urls" {
  type = list(string)
}
variable "domain_prefix" {}
variable "domain" {
  description = "The custom domain for the certificate and Cognito"
  type        = string
}
