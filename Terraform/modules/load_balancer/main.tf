#  _              _   _          _                      
# | |___  __ _ __| | | |__  __ _| |__ _ _ _  __ ___ _ _ 
# | / _ \/ _` / _` | | '_ \/ _` | / _` | ' \/ _/ -_) '_|
# |_\___/\__,_\__,_| |_.__/\__,_|_\__,_|_||_\__\___|_|  

# security group
resource "aws_security_group" "load_balancer_sg" {
  vpc_id = var.vpc_id

  ## http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "load_balancer_sg"
  }
}

# target group
resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "app-target-group"
  }
}

# lb listener
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# load balancer
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_sg.id]

  enable_deletion_protection = false

  subnets = [
    for subnet_id in var.public_subnet_id : subnet_id
  ]
}

# register app instances with target group
resource "aws_lb_target_group_attachment" "app_attachment" {
  count            = 2
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = var.app_instance_id[count.index]
  port             = 3000
}