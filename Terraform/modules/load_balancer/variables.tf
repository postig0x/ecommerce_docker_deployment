variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = list(string)
}

variable "app_instance_id" {
  type = list(string)
}
