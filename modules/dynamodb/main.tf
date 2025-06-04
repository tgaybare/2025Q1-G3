# Definición del módulo para las tablas de DynamoDB
provider "aws" {
  region = var.aws_region
}

# Tabla Users
resource "aws_dynamodb_table" "users_table" {
  name         = var.users_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "email"

  attribute {
    name = "email"
    type = "S"
  }

  # GSI para búsquedas por email
  global_secondary_index {
    name               = "EmailIndex"
    hash_key           = "email"
    projection_type    = "ALL"
    # No se especifica read/write capacity en modo on-demand
  }

  # Para Users, las búsquedas por email son globales (no están restringidas a un id específico), por lo que un GSI es necesario.

  # Habilitar cifrado en reposo
  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = var.users_table_name
    Environment = var.environment
  }
}

# Tabla Hosts
resource "aws_dynamodb_table" "hosts_table" {
  name         = var.hosts_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  # Atributos de la tabla
  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "ip"
    type = "S"
  }

  attribute {
    name = "hostname"
    type = "S"
  }

  attribute {
    name = "user_email"
    type = "S"
  }

  # GSI para búsquedas por email
  global_secondary_index {
    name               = "UserEmailIndex"
    hash_key           = "user_email"
    projection_type    = "ALL"
    # No se especifica read/write capacity en modo on-demand
  }

  # GSI para búsquedas por IP y hostname
  global_secondary_index {
    name               = "IpIndex"
    hash_key           = "ip"
    projection_type    = "ALL"
    # No se especifica read/write capacity en modo on-demand
  }

  global_secondary_index {
    name               = "HostnameIndex"
    hash_key           = "hostname"
    projection_type    = "ALL"
    # No se especifica read/write capacity en modo on-demand
  }

  # Para Hosts, las búsquedas por user_id también son globales (queremos todos los hosts de un usuario), por lo que un GSI es más apropiado.

  # Habilitar cifrado en reposo
  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = var.hosts_table_name
    Environment = var.environment
  }
}
