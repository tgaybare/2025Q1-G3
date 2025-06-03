variable "api_id" {
  description = "API Gateway HTTP API ID"
  type        = string
}

variable "api_execution_arn" {
  description = "API Gateway execution ARN"
  type        = string
}

variable "lambda_arn" {
  description = "Lambda function ARN"
  type        = string
}

variable "lambda_name" {
  description = "Lambda function name"
  type        = string
}

variable "route_key" {
  description = "Route key (e.g. GET /callback)"
  type        = string
}
