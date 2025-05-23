#########################################
###                VPC                ###
#########################################

module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  vpc_name = "Prueba module vpc"
  subnets = [
    {
      cidr_block        = var.subnet1_cidr
      availability_zone = "us-east-1a"
      name              = "subnet_1"
      public            = true
    },
    {
      cidr_block        = var.subnet2_cidr
      availability_zone = "us-east-1b"
      name              = "subnet_2"
      public            = true
    },
    {
      cidr_block        = var.subnet3_cidr
      availability_zone = "us-east-1c"
      name              = "subnet_3"
      public            = false
    },
    {
      cidr_block        = var.subnet4_cidr
      availability_zone = "us-east-1a"
      name              = "subnet_4"
      public            = false
    },
  ]
}

#########################################
###            ROUTE TABLE            ###
#########################################


#########################################
###           EC2 Instance            ###
#########################################

module "ec2_master" {
  source              = "./modules/ec2"
  instance_type       = var.master_instance_type
  subnet_id           = module.vpc.subnets["subnet_1"].id
  key_name            = var.key_name
  security_group_ids  = [aws_security_group.ec2_master.id]
  instance_name       = var.master_instance_name
  public              = module.vpc.subnets["subnet_1"].public
  user_data_path      = "${path.module}/modules/ec2/scripts/master.sh"
}

module "ec2_slave" {
  source              = "./modules/ec2"
  instance_type       = var.slave_instance_type
  subnet_id           = module.vpc.subnets["subnet_2"].id
  key_name            = var.key_name
  instance_name       = var.slave_instance_name
  public              = module.vpc.subnets["subnet_2"].public
  user_data_path      = "${path.module}/modules/ec2/scripts/slave.sh"
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
  key_name   = var.key_name
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
  vpc_id      = module.vpc.id

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
