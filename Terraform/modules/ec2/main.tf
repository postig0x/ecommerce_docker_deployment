#  _             _   _          
# | |__  __ _ __| |_(_)___ _ _  
# | '_ \/ _` (_-<  _| / _ \ ' \ 
# |_.__/\__,_/__/\__|_\___/_||_|
# - public subnet -
resource "aws_security_group" "bastion" {
  vpc_id      = var.vpc_id
  name        = "bastion-sg"
  description = "bastion sg - SSH"

  ## ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ssh"
  }

  ## outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id[count.index]
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = var.key_name

  tags = {
    Name = "ecommerce_bastion_az${count.index + 1}"
  }
}

#  __ _ _ __ _ __ 
# / _` | '_ \ '_ \
# \__,_| .__/ .__/
#      |_|  |_|   
# - private subnet -
# resource "aws_security_group" "app" {
#   vpc_id = var.vpc_id
#   name = "docker-app-sg"
#   description = "docker app sg"

#   ## ssh
#   ingress {
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = [ "0.0.0.0/0" ]
#     description = "ssh"
#   }

#   ## outbound
#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "tcp"
#     cidr_blocks = [ "0.0.0.0/0" ]
#   }
# }

resource "aws_instance" "app" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id[count.index]
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = var.key_name

  tags = {
    Name = "ecommerce_app_az${count.index + 1}"
  }
}