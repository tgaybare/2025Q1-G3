resource "random_id" "domain_suffix" {
  byte_length = 3
}

resource "aws_cognito_user_pool" "this" {
  name = "${var.user_pool_name}-${random_id.domain_suffix.hex}"

  auto_verified_attributes = ["email"]
  username_attributes = ["email"]
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
  }
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject = "Account Confirmation"
    email_message = "Your confirmation code is {####}"
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }
  admin_create_user_config {
    allow_admin_create_user_only = false
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name         = "${var.app_client_name}-${random_id.domain_suffix.hex}"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = false
  callback_urls   = var.callback_urls

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                = ["email", "openid", "profile"]
  supported_identity_providers        = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = "user-app-login-${random_id.domain_suffix.hex}"
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "null_resource" "create_admin_user" {
  provisioner "local-exec" {
    command = <<EOT
      aws cognito-idp sign-up \
        --client-id ${aws_cognito_user_pool_client.this.id} \
        --username admin@example.com \
        --password 'Admin123!@#' \
        --user-attributes Name=email,Value=admin@example.com || true

      aws cognito-idp admin-confirm-sign-up \
        --user-pool-id ${aws_cognito_user_pool.this.id} \
        --username admin@example.com || true
    EOT
  }

  depends_on = [
    aws_cognito_user_pool.this,
    aws_cognito_user_pool_client.this
  ]
}
