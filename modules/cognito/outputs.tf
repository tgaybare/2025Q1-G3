output "user_pool_id" {
  value = aws_cognito_user_pool.this.id
}

output "client_id" {
  value = aws_cognito_user_pool_client.this.id
}

output "cognito_login_url" {
  description = "Cognito Hosted UI Login URL"
  value = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${var.aws_region}.amazoncognito.com/oauth2/authorize?client_id=${aws_cognito_user_pool_client.this.id}&response_type=code&scope=openid+profile+email&redirect_uri=${urlencode(var.callback_urls[0])}"
}

output "cognito_domain" {
  description = "Cognito Hosted UI Domain"
  value = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${var.aws_region}.amazoncognito.com"
}

output "vite_authority"{
  value = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.this.id}"
}

data "aws_region" "current" {}
