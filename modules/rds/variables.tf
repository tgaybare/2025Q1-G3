variable "db_name" {
  description = "Nombre de la base de datos principal"
  type        = string
  default     = "zabbix"
}

variable "db_username" {
  description = "Usuario administrador de la base de datos"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Contraseña del usuario administrador de la base de datos"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Tipo de instancia RDS"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Tamaño de almacenamiento (GB)"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "Versión de MySQL"
  type        = string
  default     = "8.0.41"
}

variable "vpc_security_group_ids" {
  description = "Lista de IDs de security groups para la instancia RDS"
  type        = list(string)
}

variable "multi_az" {
  description = "¿Habilitar despliegue Multi-AZ?"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "La instancia RDS no debe ser accesible públicamente"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Cantidad de días de retención de backups"
  type        = number
  default     = 7
}

variable "maintenance_window" {
  description = "Ventana de mantenimiento preferida"
  type        = string
  default     = "Mon:00:00-Mon:03:00"
}

variable "subnet_ids" {
  description = "Lista de IDs de subnets de la VPC donde se desplegará la RDS. Deben ser al menos dos subnets en diferentes AZs."
  type        = list(string)
}


