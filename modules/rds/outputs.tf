output "rds_endpoint" {
  description = "Endpoint de la base de datos RDS"
  value       = aws_db_instance.this.endpoint
}

output "rds_port" {
  description = "Puerto de la base de datos RDS"
  value       = aws_db_instance.this.port
}
