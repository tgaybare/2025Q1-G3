# VPC variables

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  type    = string
  default = "zabbix-vpc"
}

variable "subnet_master_name" {
  type    = string
  default = "subnet-master"
}

variable "subnet_master_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "subnet_master_az" {
  type    = string
  default = "us-east-1a"
}

variable "subnet_rds_name_1" {
  type    = string
  default = "subnet-rds"
}

variable "subnet_rds_cidr_1" {
  type    = string
  default = "10.0.255.0/24"
}

variable "subnet_rds_az_1" {
  type    = string
  default = "us-east-1a"
}

variable "subnet_rds_name_2" {
  type    = string
  default = "subnet-rds-2"
}

variable "subnet_rds_cidr_2" {
  type    = string
  default = "10.0.254.0/24"
}

variable "subnet_rds_az_2" {
  type    = string
  default = "us-east-1b"
}

# EC2 variables

variable "master_server_name" {
  type    = string
  default = "MasterServer1"
}

variable "master_server_instance_type" {
  type    = string
  default = "t2.large"
}

variable "master_server_public" {
  type    = bool
  default = false
}

variable "master_server_key_name" {
  type    = string
  default = "ec2_key_pair"
}

variable "master_server_user_data_path" {
  type    = string
}

variable "master_security_group_name" {
  description = "Nombre del grupo de seguridad para EC2"
  type        = string
  default     = "master-ec2-sg"
}

# RDS variables

variable "db_name" {
  description = "Nombre de la base de datos principal"
  type        = string
}

variable "db_username" {
  description = "Usuario administrador de la base de datos"
  type        = string
}

variable "db_password" {
  description = "Contraseña del usuario administrador de la base de datos"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Tipo de instancia RDS"
  type        = string
}

variable "db_allocated_storage" {
  description = "Tamaño de almacenamiento (GB)"
  type        = number
}

variable "db_engine_version" {
  description = "Versión de MySQL"
  type        = string
}

variable "multi_az" {
  description = "¿Habilitar despliegue Multi-AZ de RDS?"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "¿La instancia RDS debe ser accesible públicamente?"
  type        = bool
  default = false
}

variable "backup_retention_period" {
  description = "Cantidad de días de retención de backups"
  type        = number
  default     = 7
}

variable "maintenance_window" {
  description = "Ventana de mantenimiento preferida"
  type        = string
}

variable "lambda_names" {
  type = list(string)
}
#S3 variables

variable "react_app_bucket_name" {
  description = "Nombre del bucket S3 con la app React"
  type        = string
  default     = "react-app-bucket"
}

variable "react_app_bucket_region" {
  description = "Region para el Bucket S3 con la app React"
  type        = string
}

variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos"
  type        = string
  default     = "us-east-1"
}

variable "users_table_name" {
  description = "Nombre de la tabla de usuarios en DynamoDB"
  type        = string
  default     = "users"
}

variable "hosts_table_name" {
  description = "Nombre de la tabla de hosts en DynamoDB"
  type        = string
  default     = "hosts"
}

variable "api_folder" {
    type = string
}

variable "spa_build_dir" {
  description = "Path to your SPA build directory"
  type        = string
  default     = "./front/dist"
}

variable "spa_source_dir" {
  description = "Path to your SPA directory"
  type        = string
  default     = "./front"
}

variable "callback_route_key" {
  description = "API Gateway route key for the callback"
  type        = string
  default     = "GET /callback"
}
