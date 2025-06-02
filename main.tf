#########################################
###                VPC                ###
#########################################

module "vpc_master" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
  subnets = [
    {
      cidr_block        = var.subnet_master_cidr
      availability_zone = var.subnet_master_az
      name              = var.subnet_master_name
      public            = true
    },
    {
      cidr_block        = var.subnet_rds_cidr_1
      availability_zone = var.subnet_rds_az_1
      name              = var.subnet_rds_name_1
      public            = false
    },
    {
      cidr_block        = var.subnet_rds_cidr_2
      availability_zone = var.subnet_rds_az_2
      name              = var.subnet_rds_name_2
      public            = false
    }
  ]
}

#########################################
###           EC2 Instance            ###
#########################################

module "ec2_master" {
  source              = "./modules/ec2"
  instance_type       = var.master_server_instance_type
  subnet_id           = module.vpc_master.subnets[var.subnet_master_name].id
  key_name            = aws_key_pair.ec2.key_name
  security_group_ids  = [aws_security_group.ec2_master.id]
  instance_name       = var.master_server_name
  public              = module.vpc_master.subnets[var.subnet_master_name].public
  user_data_path      = var.master_server_user_data_path
  rds_endpoint       = module.rds.rds_endpoint
  rds_port           = module.rds.rds_port
}


#########################################
###             Key Pair              ###
#########################################

resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Create the Key Pair
resource "aws_key_pair" "ec2" {
  key_name   = var.master_server_key_name
  public_key = tls_private_key.ec2.public_key_openssh
}
# Save file
resource "local_file" "ssh_key" {
  filename        = "${aws_key_pair.ec2.key_name}.pem"
  content         = tls_private_key.ec2.private_key_pem
  file_permission = "0400"
}

#########################################
###           Security Group          ###
#########################################
resource "aws_security_group" "ec2_master" {
  name        = var.master_security_group_name
  description = "allow incoming ssh connections"
  vpc_id      = module.vpc_master.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming SSH connections (Linux)"
  }

  ingress {
    from_port   = 10050
    to_port     = 10051
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming connections from slaves"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.master_security_group_name
  }
}


resource "aws_security_group" "rds-ec2-1" {
  name        = "rds-ec2-master"
  description = "Security group for RDS to allow access from EC2 master"
  vpc_id      = module.vpc_master.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_master.id]
    description = "Allow MySQL access from EC2 master"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-ec2-master"
  }
}



#########################################
###           RDS instance            ###
#########################################

module "rds" {
  source = "./modules/rds"
  db_name = var.db_name
  db_username = var.db_username
  db_password = var.db_password
  db_instance_class = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_engine_version = var.db_engine_version
  vpc_security_group_ids = [aws_security_group.rds-ec2-1.id]
  multi_az = var.multi_az
  publicly_accessible = var.publicly_accessible
  backup_retention_period = var.backup_retention_period
  maintenance_window = var.maintenance_window
  subnet_ids = [
    module.vpc_master.subnets[var.subnet_rds_name_1].id,
    module.vpc_master.subnets[var.subnet_rds_name_2].id
    ]
}

#########################################
###             LAMBDAS               ###
#########################################

locals {
  lambda_names = var.lambda_names
}

module "lambda" {
  for_each = toset(local.lambda_names)

  source = "./modules/lambda"
  name = each.key
  ec2_master_ip = module.ec2_master.public_ip
  api_folder = var.api_folder
}

#########################################
###              API GW               ###
#########################################

module "apigw" {
  for_each = module.lambda

  source = "./modules/api_gw"
  name = each.key
  lambda_arn = each.value.arn

  depends_on = [module.lambda]
}
#########################################
###             DynamoDb              ###
#########################################

module "dynamodb" {
  source = "./modules/dynamodb"

  aws_region        = var.aws_region
  environment       = "prod"
  users_table_name  = var.users_table_name
  hosts_table_name  = var.hosts_table_name

}

#########################################
###            S3 Bucket              ###
#########################################

module "react_app_bucket" {
  source = "./modules/s3"

  bucket_name   = var.react_app_bucket_name
  bucket_region = var.react_app_bucket_region
}


#########################################
###            Api-gateway            ###
#########################################


# Módulo API Gateway
module "api_gateway" {
  source = "./modules/api_gw_dynamodb"

  aws_region        = var.aws_region
  environment       = "prod"
  lambda_functions  = module.lambda_functions.functions
  users_table_name  = var.users_table_name
  hosts_table_name  = var.hosts_table_name
}

#########################################
###             Lambda                ###
#########################################

# Módulo Lambda Functions
module "lambda_functions" {
  source = "./modules/lambda_dynamodb"
  api_gateway_arn = module.api_gateway.api_gateway_arn
  aws_region        = var.aws_region
  environment       = "prod"
  users_table_name  = var.users_table_name
  hosts_table_name  = var.hosts_table_name
  api_gateway_id = module.api_gateway.api_gateway_id
}

#########################################
###             Cognito               ###
#########################################

module "cognito" {
  source          = "./modules/cognito"
  user_pool_name  = "dashboard-user-pool"
  app_client_name = "dashboard-app-client"
  domain_prefix   = "dashboard-cognito-demo"
  domain      = "dashboard-cognito-demo.example.com"

  callback_urls = [
    "https://your-api-id.execute-api.us-east-1.amazonaws.com/prod/callback"
  ]
  logout_urls = [
    "https://your-app.s3-website.us-east-1.amazonaws.com/logout"
  ]
}
