variable "vpc_id" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "public_subnet_id" {
  type = list(string)
}

variable "private_subnet_id" {
  type = list(string)
}

variable "key_name" {
  type = string
}

variable "rds_endpoint" {
  type = string
}

variable "rds_instance" {
  type = any
}