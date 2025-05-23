variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet1_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "subnet2_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "subnet3_cidr" {
  type    = string
  default = "10.0.3.0/24"
}

variable "subnet4_cidr" {
  type    = string
  default = "10.0.4.0/24"
}

variable "key_name" {
  type = string
  default = "ec2_key_pair"
}

variable "master_security_group_name" {
  type = string
  default = "ec2-master-sg"
}

variable "master_instance_name" {
  description = "Name for the master EC2 instance"
  type        = string
}

variable "slave_instance_name" {
  description = "Name for the slave EC2 instance"
  type        = string
}

variable "master_instance_type" {
  type    = string
  default = "t2.small"
}

variable "slave_instance_type" {
  type    = string
  default = "t2.micro"
}