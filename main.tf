provider "aws" {
  region     = "us-west-2"
 
}

# Target Group
resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold    = 2
    unhealthy_threshold  = 2
  }

  tags = {
    Name = "app-tg"
  }
}

# ALB
resource "aws_lb" "app_lb" {
  name                        = "app-lb"
  internal                    = false
  load_balancer_type          = "application"
  security_groups             = [aws_security_group.allow_all.id]
  subnets                     = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  enable_deletion_protection  = false
  enable_cross_zone_load_balancing = true
  idle_timeout                = 60
  tags = {
    Name = "app-lb"
  }
}

# ALB Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.app_tg.arn
      }
    }
  }
}
