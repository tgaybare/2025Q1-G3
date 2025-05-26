resource "aws_db_parameter_group" "zabbix" {
  name        = "zabbix-mysql-parameter-group"
  family      = "mysql8.0"
  description = "Parameter group for Zabbix MySQL RDS"

  parameter {
    name  = "log_bin_trust_function_creators"
    value = "1"
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "zabbix-db-subnet-group"
  subnet_ids = var.subnet_ids
  description = "Subnet group for Zabbix RDS instance"
}

resource "aws_db_instance" "this" {
  identifier              = "zabbix-db"
  engine                  = "mysql"
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = var.vpc_security_group_ids
  multi_az                = var.multi_az
  publicly_accessible     = var.publicly_accessible
  backup_retention_period = var.backup_retention_period
  maintenance_window      = var.maintenance_window
  skip_final_snapshot     = true
  deletion_protection     = false
  parameter_group_name    = aws_db_parameter_group.zabbix.name

  # Opcional: habilitar logs para troubleshooting
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
}
