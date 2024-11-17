terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.76.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"
  vpc_name = "wl6vpc"
  cidr_block = var.vpc_cidr
}

module "subnet" {
  source = "./modules/subnet"
  vpc_id = module.vpc.id
  availability_zones = var.subnet_availability_zones
  vpc_cidr_block = module.vpc.cidr_block
}

module "ec2" {
  source = "./modules/ec2"
  vpc_id = module.vpc.id
  ami_id = "AMI ID"
  instance_type = "INSTANCE TYPE"
  public_subnet_id = module.subnet.public_id
  private_subnet_id = module.subnet.private_id
  key_name = "KEY NAME"
}