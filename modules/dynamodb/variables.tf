variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "users_table_name" {
  description = "Name of the DynamoDB table for Users"
  type        = string
  default     = "Users"
}

variable "hosts_table_name" {
  description = "Name of the DynamoDB table for Hosts"
  type        = string
  default     = "Hosts"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}
