resource "aws_iam_role" "lambda_execution_role" {
  count = 0 # No crear el rol, solo para compatibilidad
  assume_role_policy = "{}" # Dummy policy para evitar error de sintaxis
}

# Empaquetado del código Lambda
data "archive_file" "get_user_by_id_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_functions/get_user_by_id.py"
  output_path = "${path.module}/lambda_functions/get_user_by_id.zip"
}

data "archive_file" "get_user_by_email_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_functions/get_user_by_email.py"
  output_path = "${path.module}/lambda_functions/get_user_by_email.zip"
}

data "archive_file" "get_hosts_by_user_id_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_functions/get_hosts_by_user_id.py"
  output_path = "${path.module}/lambda_functions/get_hosts_by_user_id.zip"
}

data "archive_file" "get_host_by_id_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_functions/get_host_by_id.py"
  output_path = "${path.module}/lambda_functions/get_host_by_id.zip"
}

# Funciones Lambda
resource "aws_lambda_function" "get_user_by_id" {
  function_name    = "get_user_by_id-${var.environment}"
  filename         = data.archive_file.get_user_by_id_zip.output_path
  source_code_hash = data.archive_file.get_user_by_id_zip.output_base64sha256
  handler          = "get_user_by_id.lambda_handler"
  runtime          = "python3.9"
  timeout          = 30
  memory_size      = 128
  role = var.lambda_execution_role_arn

  environment {
    variables = {
      USERS_TABLE_NAME = var.users_table_name
    }
  }
}

resource "aws_lambda_function" "get_user_by_email" {
  function_name    = "get_user_by_email-${var.environment}"
  filename         = data.archive_file.get_user_by_email_zip.output_path
  source_code_hash = data.archive_file.get_user_by_email_zip.output_base64sha256
  handler          = "get_user_by_email.lambda_handler"
  runtime          = "python3.9"
  timeout          = 30
  memory_size      = 128
  role = var.lambda_execution_role_arn

  environment {
    variables = {
      USERS_TABLE_NAME = var.users_table_name
    }
  }
}

resource "aws_lambda_function" "get_hosts_by_user_id" {
  function_name    = "get_hosts_by_user_id-${var.environment}"
  filename         = data.archive_file.get_hosts_by_user_id_zip.output_path
  source_code_hash = data.archive_file.get_hosts_by_user_id_zip.output_base64sha256
  handler          = "get_hosts_by_user_id.lambda_handler"
  runtime          = "python3.9"
  timeout          = 30
  memory_size      = 128
  role = var.lambda_execution_role_arn

  environment {
    variables = {
      HOSTS_TABLE_NAME = var.hosts_table_name
    }
  }
}

resource "aws_lambda_function" "get_host_by_id" {
  function_name    = "get_host_by_id-${var.environment}"
  filename         = data.archive_file.get_host_by_id_zip.output_path
  source_code_hash = data.archive_file.get_host_by_id_zip.output_base64sha256
  handler          = "get_host_by_id.lambda_handler"
  runtime          = "python3.9"
  timeout          = 30
  memory_size      = 128
  role = var.lambda_execution_role_arn

  environment {
    variables = {
      HOSTS_TABLE_NAME = var.hosts_table_name
    }
  }
}

# Data source to get the current AWS account ID
data "aws_caller_identity" "current" {}

# Permissions for API Gateway to invoke Lambda
resource "aws_lambda_permission" "get_user_by_id" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_user_by_id.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${var.api_gateway_id}/*/GET/users/{id}"
  depends_on    = [aws_lambda_function.get_user_by_id]
}

resource "aws_lambda_permission" "get_user_by_email" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_user_by_email.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${var.api_gateway_id}/*/GET/users"
  depends_on    = [aws_lambda_function.get_user_by_email]
}

resource "aws_lambda_permission" "get_hosts_by_user_id" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_hosts_by_user_id.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${var.api_gateway_id}/*/GET/hosts"
  depends_on    = [aws_lambda_function.get_hosts_by_user_id]
}

resource "aws_lambda_permission" "get_host_by_id" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_host_by_id.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${var.api_gateway_id}/*/GET/hosts/{id}"
  depends_on    = [aws_lambda_function.get_host_by_id]
}
