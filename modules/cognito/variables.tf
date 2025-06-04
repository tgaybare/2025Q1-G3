variable "user_pool_name" {}
variable "app_client_name" {}
variable "callback_urls" {
  type = list(string)
}
variable "aws_region" {
  default = "us-east-1"
}

variable "users_table_name" {}