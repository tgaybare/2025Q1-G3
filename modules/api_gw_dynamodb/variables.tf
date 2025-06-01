variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "lambda_functions" {
  description = "Map of Lambda function names to their invoke ARNs"
  type        = map(object({
    invoke_arn = string
  }))
}

variable "users_table_name" {
  description = "Name of the DynamoDB table for Users"
  type        = string
}

variable "hosts_table_name" {
  description = "Name of the DynamoDB table for Hosts"
  type        = string
}