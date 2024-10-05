# variables.tf

variable "aws_region" {
  description = "The AWS region where instances will be created"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Type of the instance"
  type        = string
  default     = "t2.micro"
}

variable "num_ubuntu_instances" {
  description = "Number of Ubuntu instances to create"
  type        = number
  default     = 4
}

variable "num_ubuntu_control_instances" {
  description = "Number of Ubuntu Control instances to create"
  type        = number
  default     = 1
}

variable "num_centos_instances" {
  description = "Number of CentOS instances to create"
  type        = number
  default     = 3
}

variable "ubuntu_ami" {
  description = "AMI ID for Ubuntu instances"
  type        = string
}

variable "centos_ami" {
  description = "AMI ID for CentOS instances"
  type        = string
}

variable "key_name" {
  description = "Name of the existing key pair"
  type        = string
}


variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "organisation" {
  type    = string
  default = "learningcircuit"
}

variable "application" {
  type    = string
  default = "application"
}

variable "environment" {
  type    = string
  default = "stage"
}

variable "username" {
  default = "custom_user"
}

variable "password" {
  default = "password123"
}