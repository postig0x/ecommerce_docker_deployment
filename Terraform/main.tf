terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.76.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source     = "./modules/vpc"
  vpc_name   = "wl6vpc"
  cidr_block = "10.0.0.0/16"
}

module "subnet" {
  source             = "./modules/subnet"
  vpc_id             = module.vpc.id
  availability_zones = ["us-east-1a", "us-east-1b"]
  vpc_cidr_block     = module.vpc.cidr_block
}

module "ec2" {
  source            = "./modules/ec2"
  vpc_id            = module.vpc.id
  ami_id            = "ami-0866a3c8686eaeeba"
  instance_type     = "t3.micro"
  public_subnet_id  = module.subnet.public_id
  private_subnet_id = module.subnet.private_id
  key_name          = "wl6key"
  rds_endpoint      = module.rds.endpoint
  rds_instance      = module.rds.instance
}

module "load_balancer" {
  source           = "./modules/load_balancer"
  vpc_id           = module.vpc.id
  public_subnet_id = module.subnet.public_id
  app_instance_id  = module.ec2.app_instance_id
}

module "rds" {
  source            = "./modules/rds"
  db_instance_class = "db.t3.micro"
  db_name           = "ecommerce"
  db_username       = "userdb"
  db_password       = "abcd1234"
  private_subnet_id = module.subnet.private_id
  vpc_id            = module.vpc.id
  app_sg_id         = module.ec2.app_sg_id
}