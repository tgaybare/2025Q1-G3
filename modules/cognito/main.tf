resource "aws_cognito_user_pool" "this" {
  name = var.user_pool_name

  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name         = var.app_client_name
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = false
  callback_urls   = var.callback_urls
  logout_urls     = var.logout_urls

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                = ["email", "openid", "profile"]
  supported_identity_providers        = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = "user-app-login-1235"
  user_pool_id = aws_cognito_user_pool.this.id

  //managed_login_version = 2
}

/*resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain
  validation_method = "DNS"

  tags = {
    Name = "CognitoDomainCertificate"
  }
}*/
/*resource "aws_cognito_user_pool_ui_customization" "this" {
  user_pool_id = aws_cognito_user_pool.this.id
  client_id    = aws_cognito_user_pool_client.this.id

  css         = ""
  image_file  = null
}*/


/*resource "aws_cognito_user_pool_domain" "this" {
  domain       = var.domain_prefix
  user_pool_id = aws_cognito_user_pool.this.id
}*/
