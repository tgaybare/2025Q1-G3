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
    },
    {
      cidr_block        = var.subnet_slave_cidr_1
      availability_zone = var.subnet_slave_az_1
      name              = var.subnet_slave_name_1
      public            = true
    },
    {
      cidr_block        = var.subnet_slave_cidr_2
      availability_zone = var.subnet_slave_az_2
      name              = var.subnet_slave_name_2
      public            = true
    },
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

  depends_on = [ 
    aws_key_pair.ec2,
    module.vpc_master
  ]
}

module "ec2_slaves" {
  source = "./modules/ec2"
  for_each = {
    "slave_1" = {
      instance_type       = var.slave_server_instance_type
      subnet_id           = module.vpc_master.subnets[var.subnet_slave_name_1].id
      instance_name       = var.slave_server_name_1
      public              = module.vpc_master.subnets[var.subnet_slave_name_1].public
      user_data_path      = var.slave_server_user_data_path
      html_content        = var.slave_server_html_content
      master_server_ip    = module.ec2_master.public_ip
    }
    "slave_2" = {
      instance_type       = var.slave_server_instance_type
      subnet_id           = module.vpc_master.subnets[var.subnet_slave_name_2].id
      instance_name       = var.slave_server_name_2
      public              = module.vpc_master.subnets[var.subnet_slave_name_2].public
      user_data_path      = var.slave_server_user_data_path
      html_content        = var.slave_server_html_content
      master_server_ip    = module.ec2_master.public_ip
    }
  }

  instance_type       = each.value.instance_type
  subnet_id           = each.value.subnet_id
  key_name            = aws_key_pair.ec2.key_name
  security_group_ids  = [aws_security_group.ec2_slave.id]
  instance_name       = each.value.instance_name
  public              = each.value.public
  user_data_path      = each.value.user_data_path
  html_content        = each.value.html_content
  master_server_ip    = each.value.master_server_ip

  depends_on = [
    aws_key_pair.ec2,
    module.ec2_master
  ]
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

resource "aws_security_group" "ec2_slave" {
  name        = var.slave_security_group_name
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
    Name = var.slave_security_group_name
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
###               SNS                 ###
#########################################
module "sns" {
  source = "./modules/sns"
  name   = var.sns_topic_name
}

#########################################
###             LAMBDAS               ###
#########################################

locals {
  lambda_names = var.lambda_names
  env_vars = {
    "EC2_MASTER_IP"    = module.ec2_master.public_ip
    "USERS_TABLE_NAME" = var.users_table_name
    "HOSTS_TABLE_NAME" = var.hosts_table_name
    "SNS_TOPIC_ARN"    = module.sns.sns_topic_arn
  }
}

module "lambda" {
  for_each = local.lambda_names

  name= each.key
  source = "./modules/lambda"
  handler = each.value.handler
  method = each.value.method
  env_vars = {
    for k in each.value.env_vars : k => local.env_vars[k]
  }
  api_folder = var.api_folder
}

#########################################
###              API GW               ###
#########################################

module "apigw" {
  for_each = var.lambda_names

  source      = "./modules/api_gw"
  name        = each.key
  lambda_arn  = module.lambda[each.key].arn
  method      = each.value.method
  api_id      = aws_apigatewayv2_api.http_api.id

  depends_on = [module.lambda]
}


resource "aws_apigatewayv2_api" "http_api" {
  name           = "http-api"
  protocol_type  = "HTTP"

  cors_configuration {
      allow_origins     = ["*"]
      allow_methods     = ["OPTIONS", "GET", "POST"]
      allow_headers     = ["Content-Type", "Authorization"]
    }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
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
###             Cognito               ###
#########################################

module "cognito" {
  source          = "./modules/cognito"
  user_pool_name  = var.user_pool_name
  app_client_name = var.app_client_name
  users_table_name = var.users_table_name

  callback_urls = [
    "${aws_apigatewayv2_api.http_api.api_endpoint}/callback",
  ]

  depends_on = [module.dynamodb]
}

# Generate .env file with Cognito configuration
resource "local_file" "env_file" {
  content = <<-EOT
VITE_REST_API_URL=${aws_apigatewayv2_api.http_api.api_endpoint}
VITE_REDIRECT_URI="${aws_apigatewayv2_api.http_api.api_endpoint}/callback"
VITE_COGNITO_USER_POOL_ID=${module.cognito.user_pool_id}
VITE_COGNITO_CLIENT_ID=${module.cognito.client_id}
VITE_AUTHORITY=${module.cognito.vite_authority}
VITE_COGNITO_HOSTED_UI=${module.cognito.cognito_login_url}
EOT

  filename = "${var.spa_source_dir}/.env"
  depends_on = [module.apigw, module.react_app_bucket, module.cognito]
}



# Copy .env to build directory and rebuild SPA (if needed)
resource "null_resource" "rebuild_spa" {
  depends_on = [local_file.env_file]

  triggers = {
    env_file_content = local_file.env_file.content
  }

  provisioner "local-exec" {
    command = "python3 ${path.module}/scripts/rebuild_spa.py ${var.spa_source_dir}"
    interpreter = ["/bin/bash", "-c"]
  }
}

# Get all files in the SPA directory
locals {
  spa_files = fileset(var.spa_build_dir, "**")
}

# Upload SPA files to S3
resource "aws_s3_object" "spa_files" {
  for_each = local.spa_files

  bucket = module.react_app_bucket.bucket_name
  key    = each.value
  source = "${var.spa_build_dir}/${each.value}"
#   etag   = filemd5("${var.spa_build_dir}/${each.value}")

  content_type = lookup({
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "json" = "application/json"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "gif"  = "image/gif"
    "svg"  = "image/svg+xml"
    "ico"  = "image/x-icon"
    "woff" = "font/woff"
    "woff2" = "font/woff2"
    "ttf"  = "font/ttf"
    "eot"  = "application/vnd.ms-fontobject"
  }, reverse(split(".", each.value))[0], "application/octet-stream")

  depends_on = [
    null_resource.rebuild_spa
  ]
}

#########################################
###             Callback Lambda      ###
#########################################

module "callback_lambda" {

  source = "./modules/callback_lambda"
  name="callback"
  api_folder = var.api_folder
  redirect_base_url = aws_apigatewayv2_api.http_api.api_endpoint
  cognito_domain = module.cognito.cognito_domain
  cognito_client_id = module.cognito.client_id
  front_redirect_url = module.react_app_bucket.website_url
  users_table_name = var.users_table_name
  depends_on = [module.dynamodb]
}

# and then add it to the API Gateway

module "add_callback_route" {
  source            = "./modules/add_endpoint_apigw"
  api_id            = aws_apigatewayv2_api.http_api.id
  api_execution_arn = aws_apigatewayv2_api.http_api.execution_arn
  lambda_arn        = module.callback_lambda.lambda_arn
  lambda_name       = module.callback_lambda.lambda_name
  route_key         = var.callback_route_key
}