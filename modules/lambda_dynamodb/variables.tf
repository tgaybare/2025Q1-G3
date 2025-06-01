variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "users_table_name" {
  description = "Name of the DynamoDB table for Users"
  type        = string
}

variable "hosts_table_name" {
  description = "Name of the DynamoDB table for Hosts"
  type        = string
}

variable "api_gateway_arn" {
  description = "ARN of the API Gateway"
  type        = string
}

variable "api_gateway_id" {
  description = "ID of the API Gateway"
  type        = string
}
