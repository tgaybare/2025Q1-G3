# Definición del API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name        = "MonitoringAPI-${var.environment}"
  description = "API for Users and Hosts management"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Recursos específicos
resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "users"
}

resource "aws_api_gateway_resource" "users_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.users.id
  path_part   = "{id}"
}

resource "aws_api_gateway_resource" "hosts" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "hosts"
}

resource "aws_api_gateway_resource" "hosts_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.hosts.id
  path_part   = "{id}"
}

# Métodos GET
resource "aws_api_gateway_method" "get_user_by_id" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.users_id.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_user_by_email" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_hosts_by_user_id" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.hosts.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_host_by_id" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.hosts_id.id
  http_method   = "GET"
  authorization = "NONE"
}

# Métodos OPTIONS para CORS
resource "aws_api_gateway_method" "options" {
  for_each = {
    users    = aws_api_gateway_resource.users.id
    users_id = aws_api_gateway_resource.users_id.id
    hosts    = aws_api_gateway_resource.hosts.id
    hosts_id = aws_api_gateway_resource.hosts_id.id
  }
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = each.value
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Integraciones con Lambda
resource "aws_api_gateway_integration" "get_user_by_id_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.users_id.id
  http_method             = aws_api_gateway_method.get_user_by_id.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_functions["get_user_by_id"].invoke_arn
}

resource "aws_api_gateway_integration" "get_user_by_email_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.users.id
  http_method             = aws_api_gateway_method.get_user_by_email.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_functions["get_user_by_email"].invoke_arn
}

resource "aws_api_gateway_integration" "get_hosts_by_user_id_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.hosts.id
  http_method             = aws_api_gateway_method.get_hosts_by_user_id.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_functions["get_hosts_by_user_id"].invoke_arn
}

resource "aws_api_gateway_integration" "get_host_by_id_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.hosts_id.id
  http_method             = aws_api_gateway_method.get_host_by_id.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_functions["get_host_by_id"].invoke_arn
}

# Integraciones OPTIONS para CORS
resource "aws_api_gateway_integration" "options_integration" {
  for_each = {
    users    = aws_api_gateway_resource.users.id
    users_id = aws_api_gateway_resource.users_id.id
    hosts    = aws_api_gateway_resource.hosts.id
    hosts_id = aws_api_gateway_resource.hosts_id.id
  }
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = each.value
  http_method             = aws_api_gateway_method.options[each.key].http_method
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
  depends_on = [aws_api_gateway_method.options]
}

# Respuestas para OPTIONS
resource "aws_api_gateway_method_response" "options_response" {
  for_each = {
    users    = aws_api_gateway_resource.users.id
    users_id = aws_api_gateway_resource.users_id.id
    hosts    = aws_api_gateway_resource.hosts.id
    hosts_id = aws_api_gateway_resource.hosts_id.id
  }
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = each.value
  http_method = aws_api_gateway_method.options[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  depends_on = [aws_api_gateway_method.options]
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  for_each = {
    users    = aws_api_gateway_resource.users.id
    users_id = aws_api_gateway_resource.users_id.id
    hosts    = aws_api_gateway_resource.hosts.id
    hosts_id = aws_api_gateway_resource.hosts_id.id
  }
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = each.value
  http_method = aws_api_gateway_method.options[each.key].http_method
  status_code = aws_api_gateway_method_response.options_response[each.key].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_integration.options_integration,
    aws_api_gateway_method_response.options_response
  ]
}

# Despliegue del API
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [
    aws_api_gateway_integration.get_user_by_id_integration,
    aws_api_gateway_integration.get_user_by_email_integration,
    aws_api_gateway_integration.get_hosts_by_user_id_integration,
    aws_api_gateway_integration.get_host_by_id_integration,
    aws_api_gateway_integration.options_integration,
    aws_api_gateway_method_response.options_response
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  stage_name    = var.environment
}
